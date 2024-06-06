module Layouts
  class Tall < Base
    def calculate
      # very first elem on the right
      left = stack[0]
      left.x = 0
      left.y = 0
      left.width = stack.size > 1 ? width / 2.0 : width
      left.height = height

      if stack.size > 1
        # the rest are going horizontal
        fw = width / 2.0
        fh = height / (stack.size - 1)
        stack[1..].each_with_index do |f, i|
          f.x = fw
          f.y = fh * i
          f.width = fw
          f.height = fh
        end
      end
    end
  end
end
