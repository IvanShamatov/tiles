module Layouts
  class Base
    attr_reader :width, :height, :stack

    def initialize(width, height, stack)
      @width, @height, @stack = width, height, stack
    end

    def resize(width, height)
      @width, @height = width, height
    end

    def calculate
      # To be implemented in subclass
    end

    def render
      calculate
      DrawText("#{self.class.name}", 50, 50, 30, BLUE)

      stack.each do |frame|
        color = stack.current == frame ? GREEN : GRAY
        if frame.x && frame.y && frame.w && frame.h
          DrawRectangleLines(frame.x + 5, frame.y + 5 , frame.w - 5 , frame.h - 5, color)
          DrawText("#{frame.content}", frame.x + 10, frame.y + 10, 30, color)
        end
      end
    end
  end
end
