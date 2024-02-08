module Layouts
  class Vertical < Base
    def place
      fw = width
      fh = height / stack.size
      stack.each_with_index do |f, i|
        f.x = 0
        f.y = fh * i
        f.w = fw
        f.h = fh
      end
    end
  end
end
