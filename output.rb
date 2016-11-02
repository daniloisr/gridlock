require 'minitest/autorun'
require 'byebug'
require 'pp'

class Grid
  Cell = Struct.new(:board, :row, :column, :symbol)

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

class Printer
  class CellDecorator < SimpleDelegator
    def nearby
      @nearby ||= {
        nw: board[row - 1, column - 1],
        n:  board[row - 1, column],
        w:  board[row, column - 1],
        c:  board[row, column]
      }
    end

    def unicode_symbol
      symbol_map[symbol]
    end

    private

    def symbol_map
      {
        nil => ' ',
        '_' => ' ',
        'X' => "\u271a",
        'T' => "\u25a0",
        'O' => "\u25cf",
      }
    end
  end

  class BoardDecorator < SimpleDelegator
    def [](row, column)
      CellDecorator.new(super(row, column))
    end

    def crossroads(row)
      width.succ.times.map do |column|
        self[row, column].nearby.values_at(:nw, :n, :w, :c)
      end
    end

    def horizontal_intersecs(row)
      width.times.map do |column|
        self[row, column].nearby.values_at(:n, :n, :c, :c)
      end
    end

    def vertical_intersecs(row)
      width.succ.times.map do |column|
        self[row, column].nearby.values_at(:w, :c, :w, :c)
      end
    end
  end

  def initialize(board)
    @board = BoardDecorator.new(board)
  end

  def print
    separators = @board.height.succ.times.map {|row| print_separator(row) }
    cells = @board.height.times.map {|row| print_cells(row) }

    separators.zip(cells).flatten.compact
  end

  private

  def print_separator(row)
    crossroads = @board.crossroads(row).map(&method(:separator_for))
    intersects =
      @board.horizontal_intersecs(row)
      .map(&method(:separator_for))
      .map {|sep| sep * 3 }

    crossroads.zip(intersects).flatten.compact.join
  end

  def print_cells(row)
    intersects = @board.vertical_intersecs(row).map(&method(:separator_for))
    cells = @board.width.times.map do |column|
      " #{@board[row, column].unicode_symbol} "
    end

    intersects.zip(cells).flatten.compact.join
  end

  def separator_for(intersect)
    symbols = intersect.map(&:symbol)
    key = symbols[1..3].
      map {|sym| symbols.uniq.index(sym) }.
      join

    separator_map[key]
  end

  def separator_map
    {
      '000' => ' ',
      '001' => "\u250c",
      '010' => "\u2510",
      '011' => "\u2500",
      '012' => "\u252c",
      '100' => "\u2514",
      '101' => "\u2502",
      '102' => "\u251c",
      '110' => "\u253c",
      '111' => "\u2518",
      '112' => "\u253c",
      '120' => "\u253c",
      '121' => "\u2524",
      '122' => "\u2534",
      '123' => "\u253c",
    }
  end
end

class PrinterTest < Minitest::Test
  def test_print_single_cell
    board = Board.new(1, 'T')
    printer = Printer.new(board)
    expected = [
      '┌───┐',
      '│ ■ │',
      '└───┘',
    ]

    assert_equal expected, printer.print
  end

  def test_print_multiple_cells
    board = Board.new(3, 'TOOXTOXO')

    assert Printer.new(board).print == [
      '┌───┬───────┐',
      '│ ■ │ ●   ● │',
      '├───┼───┐   │',
      '│ ✚ │ ■ │ ● │',
      '│   ├───┼───┘',
      '│ ✚ │ ● │    ',
      '└───┴───┘    ',
    ]
  end
end
