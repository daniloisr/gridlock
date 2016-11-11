class Grid
  Cell = Struct.new(:symbol, :filled)

  attr_reader :width, :height, :symbols

  def initialize(width, symbols)
    @width = width
    @symbols = symbols
    @height = (symbols.size / width.to_f).ceil
    @cells = {}
  end

  def skipped_at
    @symbols.slice(/^_*[^_]/).size - 1
  end

  def [](row, column = nil)
    row, column = [row / width, row % width] if column == nil

    @cells[[row, column]] ||= Cell.new.tap do |cell|
      if row.between?(0, height - 1) && column.between?(0, width - 1)
        cell.symbol = @symbols[row * width + column]
      end
    end
  end
end

Piece = Board = Grid
