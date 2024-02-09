module Layouts
  class Wide < Base
    def calculate
      # very first elem on the top
      left = stack[0]
      left.x = 0
      left.y = 0
      left.w = width
      left.h = stack.size > 1 ? height / 2.0 : height

      if stack.size > 1
        # the rest are going horizontal
        fw = width / (stack.size - 1)
        fh = height / 2.0
        stack[1..].each_with_index do |f, i|
          f.x = fw * i
          f.y = fh
          f.w = fw
          f.h = fh
        end
      end
    end
  end
end
