require 'matrix'

class Point
  include Comparable

  def self.from_index(index, width)
    self.new(index / width, index % width)
  end

  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def +(other)
    self.class.new(@x + other.x, @y + other.y)
  end

  def -(other)
    self.class.new(@x - other.x, @y - other.y)
  end

  def <=>(other)
    return -1 if @x < other.x
    return -1 if @x == other.x && @y < other.y
    return  0 if @y == other.y
    return  1
  end

  def to_s
    "Point[#{@x},#{@y}]"
  end

  def inspect
    "Point[#{@x},#{@y}]"
  end
end

Cell = Struct.new(:symbol, :piece)
NullCell = Cell.new

Board = Piece = Grid =
Class.new do
  attr_reader :width, :height, :symbols, :cells

  def initialize(width, symbols:, cells: nil)
    @width = width
    @height = (symbols.size / width.to_f).ceil
    @symbols = symbols
    @cells = cells or init_cells
  end

  def [](key)
    @cells[key] or NullCell
  end

  private

  def init_cells
    index_to_vector = -> (i) { Vector[i / @width, i % @width] }
    build_cell = -> (symbol) { Cell.new(symbol, self) }

    symbols.size.times
      .map(&index_to_vector)
      .zip(symbols.chars.map(&build_cell))
      .to_h
  end
end
