require 'grid'

class Printer
  SEPARATOR_MAP = {
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

  class CellDecorator < SimpleDelegator
    SYMBOL_MAP = {
      nil => ' ',
      '_' => ' ',
      'X' => "\u271a",
      'T' => "\u25a0",
      'O' => "\u25cf",
    }

    def nearby
      @nearby ||= {
        nw: grid[row - 1, column - 1],
        n:  grid[row - 1, column],
        w:  grid[row, column - 1],
        c:  grid[row, column]
      }
    end

    def unicode_symbol
      SYMBOL_MAP[symbol]
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

    SEPARATOR_MAP[key]
  end
end
