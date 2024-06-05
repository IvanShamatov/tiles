module Layouts
  class Base
    attr_reader :display, :stack, :width, :height

    def initialize(display, stack)
      @display, @stack = display, stack
      @width = 1280
      @height = 720
    end

    def recalculate
      return if stack.size.zero?
      # To be implemented in subclass
      calculate
    end

    def focussed_window(x, y)
      stack.find do |tile|
        tile.x <= x &&
          tile.y <= y &&
          tile.x + tile.w > x &&
          tile.y + tile.h > y
      end
    end

    def render
      recalculate
      binding.pry

      stack.each do |tile|
        color = stack.current == wind ? GREEN : BLACK
        if tile.x && tile.y && tile.width && tile.height
          tile.configure
          tile.show
        end
      end
    end
  end
end
