module Layouts
  require_relative 'base'
  require_relative 'columns'
  require_relative 'rows'
  require_relative 'tall'
  require_relative 'wide'
  require_relative 'grid'
  require_relative 'max'
  # require_relative 'split'
  # require_relative 'fibonacci'
  # require_relative 'three_columns'

  AVAILABLE = [
    Layouts::Columns,
    Layouts::Rows,
    Layouts::Wide,
    Layouts::Tall,
    Layouts::Grid,
    Layouts::Max,
    # Layouts::Split,
    # Layouts::Fibonacci,
    # Layouts::ThreeColumns
  ]
end
