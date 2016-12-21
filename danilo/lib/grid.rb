require 'point'

class Grid
  Cell = Struct.new(:symbol, :piece_id) do
    def inspect
      format "Cell('%s',%s)", symbol, piece_id
    end
  end

  attr_reader :id, :width, :height, :symbols
  attr_accessor :cells

  def self.next_id
    @id ||= -1
    @id += 1
  end

  def initialize(width, symbols, cells: nil)
    @id = self.class.next_id
    @width = width
    @height = (symbols.size / width.to_f).ceil
    @symbols = symbols
    @cells = cells || init_cells
  end

  def cell(*args)
    point = args.size == 2 ? Point.new(*args) : args.first
    @cells[point] = Cell.new unless @cells[point]

    @cells[point]
  end

  def inspect
    format '%dx%d "%s" %s', width, height, symbols, cells
  end

  def initialize_clone(other)
    other.cells = cells.map { |point, cell| [point, cell.clone] }.to_h
  end

  private

  def init_cells
    Array
      .new(symbols.size) { |index| Point.from_index(index, @width) }
      .zip(symbols.chars.map { |symbol| Cell.new(symbol, nil) })
      .to_h
  end
end

Board = Piece = Grid
