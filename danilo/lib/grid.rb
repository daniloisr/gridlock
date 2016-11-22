class Grid
  Cell = Struct.new(:symbol, :filled, :filled_with)

  attr_reader :width, :height, :symbols, :cells

  def initialize(width, symbols, height = nil)
    @width = width
    @height = (symbols.size / width.to_f).ceil
    @symbols = symbols
    @cells = {}
  end

  def [](row, column = nil)
    row, column = [row / width, row % width] if column == nil

    @cells[[row, column]] ||= Cell.new.tap do |cell|
      if row.between?(0, height - 1) && column.between?(0, width - 1)
        cell.symbol = @symbols[row * width + column]
      end
    end
  end

  def initialize_copy(other)
    @cells = other.cells.map {|k,v| [k, v.dup] }.to_h
  end
end

class Board < Grid
  def skipped_at
    @symbols.slice(/^_*[^_]/).size - 1
  end
end

class Piece < Grid
  def initialize(width, symbols, is_available = true)
    super(width, symbols)
    @is_available = true
  end

  def available?
    @is_available
  end

  def use
    @is_available = false
  end
end
