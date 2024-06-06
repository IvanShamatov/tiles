# frozen_string_literal: true

class Manager
  INPUT_MASK  = Events::SUBSTRUCTURE_REDIRECT_MASK
  ROOT_MASK   = Events::PROPERTY_CHANGE_MASK |
                Events::SUBSTRUCTURE_REDIRECT_MASK |
                Events::SUBSTRUCTURE_NOTIFY_MASK |
                Events::STRUCTURE_NOTIFY_MASK
  DEFAULT_GEO = Uh::Geo.new(0, 0, 320, 240).freeze

  KEY_MODIFIERS = {
    shift: 1 << 0,
    lock: 1 << 1,
    ctrl: 1 << 2,
    mod1: 1 << 3,
    mod2: 1 << 4,
    mod3: 1 << 5,
    mod4: 1 << 6,
    mod5: 1 << 7
  }.freeze

  attr_reader :modifier, :modifier_ignore, :display, :tiles

  def initialize(runner)
    @runner = runner
    @display = Uh::Display.new
    @stack = Stack.new # window stack
    @modifier = :ctrl
    @modifier_ignore = []
    @keybinds = {
      [:Return]     => proc { execute 'rofi -show' },
      [:Left] => proc { focus_prev },
      [:Right] => proc { focus_next },
      [:Up] => proc { swap_prev },
      [:Down] => proc { swap_next },
      [:Escape] => proc { next_layout },
    }.freeze
  end

  def focus_prev
    @stack.focus_prev
    @layout.render
  end

  def focus_next
    @stack.focus_next
    @layout.render
  end

  def swap_prev
    @stack.swap_prev
    @layout.render
  end

  def swap_next
    @stack.swap_next
    @layout.render
  end

  def next_layout
    i = Layouts::AVAILABLE.index(@layout.class)
    @layout = Layouts::AVAILABLE[i-1].new(@display, @stack)
    @layout.render
  end

  def to_io
    IO.new(@display.fileno)
  end

  def connect
    $logger.info "Connecting to X server on `#{display}'"
    @display.open

    check_other_wm!
    Uh::Display.on_error { |*args| handle_error(*args) }
    @display.sync false

    @layout = Layouts::AVAILABLE[0].new(@display, @stack)
    $logger.info "Connected to X server on `#{display}'"

    @display.root.mask = ROOT_MASK

    @keybinds.each_key { |keysym| grab_key(*keysym) }
  end

  def disconnect
    @display.close
    $logger.info 'Disconnected from X server'
  end

  def flush
    @display.flush
  end

  def grab_key(keysym, _mod = nil)
    mod_mask = KEY_MODIFIERS[@modifier]
    combine_modifier_masks(@modifier_ignore) do |ignore_mask|
      @display.grab_key keysym.to_s, mod_mask | ignore_mask
    end
  end

  def evaluate(code = nil, &block)
    if code
      instance_exec(&code)
    else
      instance_exec(&block)
    end
  end

  def execute(command)
    $logger.info "Execute: #{command}"
    pid = fork do
      fork do
        Process.setsid
        begin
          exec command
        rescue Errno::ENOENT => e
          $logger.info "ExecuteError: #{e}"
        end
      end
    end
    Process.waitpid pid
  end

  def tile_for(window)
    @stack.find { |e| e.window == window }
  end

  def handle_next_event
    handle @display.next_event
  end

  def handle(event)
    case event.type
    when :key_press
      handle_key_press(event)
    when :map_request
      handle_map_request(event)
    when :destroy_notify
      handle_destroy_notify(event)
    when :error
      handle_error(event)
    # when :configure_notify
    #   handle_configure_notify(event)

    # when :configure_request
    #   handle_configure_request(event)
    # when :create_notify
    #   handle_create_notify(event)
    # when :expose
    #   handle_expose(event)
    # when :property_notify
    #   handle_property_notify(event)
    # when :unmap_notify
    #   handle_unmap_notify(event)
    # else
    #   log_event(event)
    end
  end

  private

  def handle_error(*error)
    if error.none? || error.nil?
      $logger.info 'Fatal X IO Error received'
    else
      XEventLogger.new($logger).log_xerror(*error)
    end
  end

  def handle_key_press(event)
    XEventLogger.new($logger).log_event(event)
    case remove_modifier_masks event.modifier_mask, @modifier_ignore
    when KEY_MODIFIERS[@modifier]
      if @keybinds.key?([event.key.to_sym])
        evaluate(@keybinds[[event.key.to_sym]])
      end
    when KEY_MODIFIERS[@modifier] | KEY_MODIFIERS[:shift]
      $logger.info event.key.to_sym
    end
  end

  def handle_configure_request(event)
    window = event.window
    $logger.info "Configuring window: #{window}"

    if (tile = tile_for(window))
      tile.configure
    else
      geo = @layout.suggest_geo
      window.configure_event geo || DEFAULT_GEO
    end
  end

  def handle_configure_notify(event)
    window = event.window
    $logger.info "Configuring nofity: #{window}"

    # if (tile = tile_for(window))
    #   tile.configure
    # else
    #   geo = @layout.suggest_geo
    #   window.configure_event geo || DEFAULT_GEO
    # end
  end

  def log_event(event)
    XEventLogger.new($logger).log_event(event)
  end

  def handle_destroy_notify(event)
    return unless (tile = tile_for(event.window))

    unmanage tile
  end

  def handle_expose(event)
    $logger.info "Exposing window: #{event.window}"
    @layout.expose(event.window)
  end

  def handle_map_request(event)
    window = event.window
    return if window.override_redirect? || tile_for(window)

    tile = Tile.new(window, Uh::Geo.new())
    @stack.place(tile)
    $logger.info "Managing tile #{tile}"

    @layout.render
    @display.listen_events window, Events::PROPERTY_CHANGE_MASK
  end

  def handle_property_notify(event)
    window = event.window
    return unless (tile = tile_for(window))

    tile.update_window_properties
    $logger.info "Updating client #{tile}"

    @layout.update(tile)
  end

  def handle_unmap_notify(event)
    unmap event.window
  end

  def unmanage(tile)
    @stack.delete tile
    $logger.info "Unmanaging client #{tile}"
    @layout.render
  end

  def check_other_wm!
    Uh::Display.on_error { raise OtherWMRunningError }
    @display.listen_events INPUT_MASK
    @display.sync false
  end

  def combine_modifier_masks(mods)
    yield 0
    (1..mods.size).flat_map { |n| mods.combination(n).to_a }.each do |cmb|
      yield cmb.map { |e| KEY_MODIFIERS[e] }.inject(&:|)
    end
  end

  def remove_modifier_masks(mask, remove)
    return mask unless remove.any?

    mask & ~@modifier_ignore
           .map { |e| KEY_MODIFIERS[e] }
           .inject(&:|)
  end
end
