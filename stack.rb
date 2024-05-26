require 'forwardable'

class Stack
  attr_reader :arr, :current_index
  extend Forwardable

  def_delegators :@arr, :size, :map, :each, :each_with_index, :[], :select

  Tile = Struct.new(:x, :y, :w, :h, :content)
  def initialize
    @arr = [Tile.new(nil, nil, nil, nil, 0)]
    @current_index = 0
  end

  def <<(tile)
    @current_index += 1
    @arr.insert(@current_index, tile)
  end

  def del
    unless @arr.size == 1
      @arr.delete_at(@current_index)
      @current_index -=1
    end
  end

  def current
    @arr[@current_index]
  end

  def focus_prev
    @current_index = (@current_index - 1) % @arr.size
  end

  def focus_next
    @current_index = (@current_index + 1) % @arr.size
  end

  def swap_prev
    prev = (@current_index - 1) % @arr.size
    @arr[@current_index], @arr[prev] = @arr[prev], @arr[@current_index]
    @current_index = prev
  end

  def swap_next
    _next = (@current_index + 1) % @arr.size
    @arr[@current_index], @arr[_next] = @arr[_next], @arr[@current_index]
    @current_index = _next
  end
end
