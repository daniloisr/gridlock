require 'point'

class Grid
  Cell = Struct.new(:symbol, :piece)
  NullCell = Cell.new

  attr_reader :width, :height, :symbols, :cells

  def initialize(width, symbols:, cells: nil)
    @width = width
    @height = (symbols.size / width.to_f).ceil
    @symbols = symbols
    @cells = cells || init_cells
  end

  def [](key)
    @cells[key] || NullCell
  end

  private

  def init_cells
    symbols.size.times
      .map { |index| Point.from_index(index, @width) }
      .zip(symbols.chars.map {|symbol| Cell.new(symbol, self) })
      .to_h
  end
end

Board = Piece = Grid
