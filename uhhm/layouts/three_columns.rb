module Layouts
  class ThreeColumns < Base
    def calculate
      # if one, it maxes

      # if two 70/30


      if stack.current.x.nil? || stack.current.y.nil?
        tile_to_split = stack[stack.current_index - 1]
        if tile_to_split.w >= tile_to_split.h
          split_columns(tile_to_split, stack.current)
        else
          split_rows(tile_to_split, stack.current)
        end
      end
    end

    def split_columns(tile_to_split, current)
      fw = tile_to_split.w / 2

      [tile_to_split, current].each_with_index do |f, i|
        f.x = tile_to_split.x + fw * i
        f.y = tile_to_split.y
        f.w = fw
        f.h = tile_to_split.h
      end
    end

    def split_rows(tile_to_split, current)
      fh = tile_to_split.h / 2

      [tile_to_split, current].each_with_index do |f, i|
        f.x = tile_to_split.x
        f.y = tile_to_split.y + fh * i
        f.w = tile_to_split.w
        f.h = fh
      end
    end
  end
end
