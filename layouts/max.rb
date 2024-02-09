module Layouts
  class Max < Base
    def calculate
      stack.each do |f|
        f.x = nil
        f.y = nil
        f.w = nil
        f.h = nil
      end
      stack.current
      stack.current.x = 0
      stack.current.y = 0
      stack.current.w = width
      stack.current.h = height
    end
  end
end
