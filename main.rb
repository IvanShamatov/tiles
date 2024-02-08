require 'bundler'
Bundler.require

require_relative 'utils/setup_dll'
require_relative 'utils/helpers'
require_relative 'layouts/all'

SCREEN_WIDTH = 1600
SCREEN_HEIGHT = 1000

class Game
  include RLHelpers

  attr_accessor :layout

  LAYOUTS = [
    Layouts::Horizontal,
    Layouts::Wide,
    Layouts::Tall,
    Layouts::Vertical,
  ]

  def initialize
    @layout = Layouts::Horizontal.new(SCREEN_WIDTH, SCREEN_HEIGHT)
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
      @layout.add
    end

    if is_key_pressed(KEY_R)
      i = LAYOUTS.index(@layout.class)
      @layout = LAYOUTS[i-1].new(GetScreenWidth(), GetScreenHeight())
    end

    if IsWindowResized()
      @layout.resize(GetScreenWidth(), GetScreenHeight())
    end

    if is_key_pressed(KEY_THREE)
    end

    if is_key_pressed(KEY_FOUR)
    end
  end

  def draw
    drawing do
      clear_background(BLACK)
      layout.draw
    end
  end
end


Game.new.show


