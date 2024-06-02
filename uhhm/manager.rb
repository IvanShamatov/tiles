# frozen_string_literal: true

class Manager
  INPUT_MASK  = Events::SUBSTRUCTURE_REDIRECT_MASK
  ROOT_MASK   = Events::PROPERTY_CHANGE_MASK |
                Events::SUBSTRUCTURE_REDIRECT_MASK |
                Events::SUBSTRUCTURE_NOTIFY_MASK |
                Events::STRUCTURE_NOTIFY_MASK
  DEFAULT_GEO = Geo.new(0, 0, 320, 240).freeze

  KEY_MODIFIERS = {
    shift:  1 << 0,
    lock:   1 << 1,
    ctrl:   1 << 2,
    mod1:   1 << 3,
    mod2:   1 << 4,
    mod3:   1 << 5,
    mod4:   1 << 6,
    mod5:   1 << 7
  }.freeze

  attr_reader :modifier, :modifier_ignore, :display, :tiles

  def initialize
    @display = Uh::Display.new
    @stack = Stack.new # window stack
    @layout = Layout.new
    @modifier         = :mod1
    @modifier_ignore  = []
  end

  def to_io
    IO.new(@display.fileno)
  end

  def connect
    log_debug "Connecting to X server on `#{display}'"
    @display.open
    check_other_wm!
    Uh::Display.on_error { |*args| handle_error(*args) }
    @display.sync false

    log "Connected to X server on `#{display}'"
    layout.register(@display)

    @display.root.mask = ROOT_MASK
  end

  def disconnect
    @display.close
    log 'Disconnected from X server'
  end

  def flush
    @display.flush
  end

  def grab_key(keysym, mod = nil)
    mod_mask = KEY_MODIFIERS[@modifier]
    combine_modifier_masks(@modifier_ignore) do |ignore_mask|
      @display.grab_key keysym.to_s, mod_mask | ignore_mask
    end
  end

  def configure(window)
    if (tile = tile_for(window))
      tile.configure
    else
      log "Configuring window: #{window}"
      geo = layout.suggest_geo
      window.configure_event geo || DEFAULT_GEO
    end
  end

  def map(window)
    return if window.override_redirect? || tile_for(window)

    @tiles << tile = tile.new(window)
    log "Managing client #{client}"
    layout << tile
    @display.listen_events window, Events::PROPERTY_CHANGE_MASK
  end

  def unmap(window)
    return unless (tile = tile_for(window))

    if tile.unmap_count.positive?
      tile.unmap_count -= 1
    else
      unmanage tile
    end
  end

  def destroy(window)
    return unless (tile = tile_for(window))

    unmanage tile
  end

  def update_properties(window)
    return unless (tile = tile_for(window))

    tile.update_window_properties
    log "Updating client #{tile}"

    layout.update(tile)
  end

  def handle_next_event
    handle @display.next_event
  end

  def handle_pending_events
    handle_next_event while @display.pending?
  end

  def handle(event)
    XEventLogger.new(@logger).log_event event
  # end
    # case event.type
    # when 'error'
    #   handle_error(event)
    # when 'key_pressed'
    #   handle_key_pressed(event)
    # when 'configure_request'
    #   handle_configure_request(event)
    # when 'destroy_notify'
    #   handle_destroy_notify(event)
    # when 'expose'
    #   handle_expose(event)
    # when 'map_request'
    #   handle_map_request(event)
    # when 'property_notify'
    #   handle_property_notify(event)
    # when 'unmap_notify'
    #   handle_unmap_notify(event)
    # end
  end


  private

  def handle_error(*error)
    if error.none?
      log_fatal 'Fatal X IO Error received'
    else
      XEventLogger.new(@logger).log_xerror(*error)
    end
  end

  def handle_key_press(event)
    case remove_modifier_masks event.modifier_mask, @modifier_ignore
    when KEY_MODIFIERS[@modifier]
      @dispatcher.emit :key, event.key.to_sym
    when KEY_MODIFIERS[@modifier] | KEY_MODIFIERS[:shift]
      @dispatcher.emit :key, event.key.to_sym, :shift
    end
  end

  def handle_configure_request(event)
    configure event.window
  end

  def handle_destroy_notify(event)
    destroy event.window
  end

  def handle_expose(event)
    log "Exposing window: #{event.window}"
    layout.expose(event.window)
  end

  def handle_map_request(event)
    map event.window
  end

  def handle_property_notify(event)
    update_properties event.window
  end

  def handle_unmap_notify(event)
    unmap event.window
  end

  def tile_for(window)
    @tiles.find { |e| e.window == window }
  end

  def unmanage(tile)
    @tiles.delete tile
    log "Unmanaging client #{tile}"
    layout.remove tile  def handle(event)
    XEventLogger.new(@logger).log_event event
  end

  def check_other_wm!
    Display.on_error { raise OtherWMRunningError }
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
