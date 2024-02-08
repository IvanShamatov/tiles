module Layouts
  class Base
    Frame = Struct.new(:x, :y, :w, :h, :c)

    attr_accessor :width, :height
    attr_reader :current_frame, :stack

    def initialize(width, height)
      @width, @height = width, height
      @stack = []
      add()
      @current_frame = @stack.first
    end

    def add
      new_frame = Frame.new(nil, nil, nil, nil)
      @current_frame = new_frame
      @stack << new_frame
      place
    end

    def resize(width, height)
      @width, @height = width, height
      place
    end

    def place
      # To be implemented in subclass
    end

    def draw
      DrawText("#{self.class.name}", 50, 50, 30, BLUE)
      stack.each_with_index do |f, i|
        color = current_frame == f ? GREEN : GRAY
        DrawRectangleLines(f.x + 5, f.y + 5 , f.w - 5 , f.h - 5, color)
        DrawText("#{i}", f.x + 10, f.y + 10, 30, color)
      end
    end
  end
end
