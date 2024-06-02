module Layouts
  class Grid < Base
    def calculate
      if stack.size <= 2
        aline_pack(stack, 0, height)
      else
        top_pack = stack[0...stack.size/2]
        bottom_pack = stack[stack.size/2..-1]

        aline_pack(top_pack, 0, height / 2)
        aline_pack(bottom_pack, height / 2, height / 2)
      end
    end

    def aline_pack(pack, y, fh)
      fw = width / pack.size
      pack.each_with_index do |f, i|
        f.x = fw * i
        f.y = y
        f.w = fw
        f.h = fh
      end
    end
  end
end
