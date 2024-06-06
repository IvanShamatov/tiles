module Layouts
  class Columns < Base
    def calculate
      fw = width / stack.size
      fh = height
      stack.each_with_index do |f, i|
        f.x = fw * i
        f.y = 0
        f.width = fw
        f.height = fh
      end
    end
  end
end
