module Layouts
  class Rows < Base
    def calculate
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
