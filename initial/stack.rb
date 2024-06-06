require 'forwardable'

class Stack
  extend Forwardable

  def_delegators :@arr, :size, :map, :each, :each_with_index, :[], :select, :find

  def initialize
    @arr = []
    @focus = 0
  end

  def place(window)
    @arr << window
    @focus = @arr.index(window)
  end

  def delete_focused
    @arr.delete_at(@focus)
    @focus -=1
  end

  def focus(window)
    @focus = @arr.index(window)
  end

  def current
    @arr[@focus]
  end

  def focus_prev
    @focus = (@focus - 1) % @arr.size
  end

  def focus_next
    @focus = (@focus + 1) % @arr.size
  end

  def swap_prev
    prev = (@focus - 1) % @arr.size
    @arr[@focus], @arr[prev] = @arr[prev], @arr[@focus]
    @focus = prev
  end

  def swap_next
    _next = (@focus + 1) % @arr.size
    @arr[@focus], @arr[_next] = @arr[_next], @arr[@focus]
    @focus = _next
  end
end
