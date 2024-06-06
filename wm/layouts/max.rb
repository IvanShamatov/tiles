module Layouts
  class Max < Base
    def calculate
      stack.each do |f|
        # hiding all windows, showing just one
        f.x = nil
        f.y = nil
        f.width = nil
        f.height = nil
      end
      stack.current
      stack.current.x = 0
      stack.current.y = 0
      stack.current.width = width
      stack.current.height = height
    end

    def focussed_window(_x, _y)
      stack.current
    end
  end
end
