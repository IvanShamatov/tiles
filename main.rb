require 'bundler'
Bundler.require

require_relative 'utils/setup_dll'
require_relative 'utils/helpers'
require_relative 'layouts/all'
require_relative 'stack'

SCREEN_WIDTH = 1600
SCREEN_HEIGHT = 1000

class Window
  include RLHelpers

  attr_accessor :layout, :stack

  def initialize
    @stack = Stack.new
    @layout = Layouts::AVAILABLE[0].new(SCREEN_WIDTH, SCREEN_HEIGHT, @stack)
  end

  def show
    set_target_fps(60)
    set_config_flags(FLAG_WINDOW_RESIZABLE)

    window(SCREEN_WIDTH, SCREEN_HEIGHT, "screen") do
      # Main game loop
      until window_should_close? do # Detect window close button or ESC key
        update
        draw
      end
    end
  end

  def update
    if is_key_pressed(KEY_F)
      # adding new tile to the stack
      stack << Stack::Tile.new(nil, nil, nil, nil, stack.size)
    end

    if is_key_pressed(KEY_R)
      i = Layouts::AVAILABLE.index(@layout.class)
      self.layout = Layouts::AVAILABLE[i-1].new(GetScreenWidth(), GetScreenHeight(), stack)
    end

    if IsWindowResized()
      layout.resize(GetScreenWidth(), GetScreenHeight())
    end

    # move focus from the current tile to the previous one
    if is_key_pressed(KEY_LEFT)
      stack.focus_prev
    end

    # move focus from the current tile to the next one
    if is_key_pressed(KEY_RIGHT)
      stack.focus_next
    end

    # swap current tile with the previous one
    if is_key_pressed(KEY_UP)
      stack.swap_prev
    end

    # swap current tile with the next one
    if is_key_pressed(KEY_DOWN)
      stack.swap_next
    end
  end

  def draw
    drawing do
      clear_background(BLACK)
      layout.render
    end
  end
end

Window.new.show
