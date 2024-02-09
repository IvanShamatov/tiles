module Layouts
  class Horizontal < Base
    def calculate
      super
      fw = width / stack.size
      fh = height
      stack.each_with_index do |f, i|
        f.x = fw * i
        f.y = 0
        f.w = fw
        f.h = fh
      end
    end
  end
end
