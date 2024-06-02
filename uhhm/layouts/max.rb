module Layouts
  class Max < Base
    def calculate
      stack.each do |f|
        # hiding all windows, showing just one
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

    def focussed_window(_x, _y)
      stack.current
    end
  end
end
