module Layouts
  class Split < Base
    def calculate
      if stack.current.x.nil? || stack.current.y.nil?
        prev = stack[stack.current_index - 1]
        column = stack.select {|t| t.x == prev.x && t.width == prev.width }
        row = stack.select {|t| t.y == prev.y && t.height == prev.height }

        if column.size >= row.size
          split_rows(row + [stack.current])
        else
          split_columns(column + [stack.current])
        end
      end
    end

    def split_columns(pack)
      tile = pack.first
      fw = tile.width / pack.size

      pack.each_with_index do |f, i|
        f.x = tile.x + fw * i
        f.y = tile.y
        f.width = fw
        f.height = tile.height
      end
    end

    def split_rows(pack)
      tile = pack.first
      fh = tile.height / pack.size

      pack.each_with_index do |f, i|
        f.x = tile.x
        f.y = tile.y + fh * i
        f.width = tile.width
        f.height = fh
      end
    end
  end
end
