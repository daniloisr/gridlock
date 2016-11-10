class Grid
  Cell = Struct.new(:grid, :row, :column, :symbol)

  attr_reader :width, :height

  def initialize(width, cells)
    @width = width
    @cells = cells
    @height = (cells.size / width.to_f).ceil
  end

  def solve(pieces)
    @pieces = pieces
  end

  def [](row, column)
    Cell.new(self, row, column).tap do |cell|
      if row.between?(0, @height - 1) && column.between?(0, @width - 1)
        cell.symbol = @cells[row * width + column]
      end
    end
  end
end

Piece = Board = Grid

