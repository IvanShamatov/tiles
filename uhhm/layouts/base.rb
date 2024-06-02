module Layouts
  class Base
    attr_reader :width, :height, :stack

    def initialize(width, height, stack)
      @width, @height, @stack = width, height, stack
    end

    def resize(width, height)
      @width, @height = width, height
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
          tile.x+tile.w > x &&
          tile.y+tile.h > y
      end
    end

    def render
      recalculate

      stack.each do |frame|
        color = stack.current == frame ? GREEN : BLACK
        if frame.x && frame.y && frame.w && frame.h
          DrawRectangle(frame.x, frame.y, frame.w, frame.h, frame.color)
          rectangle = Rectangle.create(frame.x + 5, frame.y + 5 , frame.w - 5 , frame.h - 5)
          DrawRectangleLinesEx(rectangle, 10, color)
          DrawText("#{frame.content}", frame.x + 20, frame.y + 20, 50, BLACK)
        end
      end
      DrawText("#{self.class.name}", 50, 50, 50, BLACK)
    end
  end
end
