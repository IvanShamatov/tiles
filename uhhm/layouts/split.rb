module Layouts
  class Split < Base
    def calculate
      if stack.current.x.nil? || stack.current.y.nil?
        prev = stack[stack.current_index - 1]
        column = stack.select {|t| t.x == prev.x && t.w == prev.w }
        row = stack.select {|t| t.y == prev.y && t.h == prev.h }

        if column.size >= row.size
          split_rows(row + [stack.current])
        else
          split_columns(column + [stack.current])
        end
      end
    end

    def split_columns(pack)
      tile = pack.first
      fw = tile.w / pack.size

      pack.each_with_index do |f, i|
        f.x = tile.x + fw * i
        f.y = tile.y
        f.w = fw
        f.h = tile.h
      end
    end

    def split_rows(pack)
      tile = pack.first
      fh = tile.h / pack.size

      pack.each_with_index do |f, i|
        f.x = tile.x
        f.y = tile.y + fh * i
        f.w = tile.w
        f.h = fh
      end
    end
  end
end
