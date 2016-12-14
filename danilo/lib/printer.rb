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
    '123' => "\u253c"
  }.freeze

  class CellDecorator < SimpleDelegator
    SYMBOL_MAP = {
      nil => ' ',
      '_' => ' ',
      'X' => "\u271a",
      'T' => "\u25a0",
      'O' => "\u25cf"
    }.freeze

    def unicode_symbol
      SYMBOL_MAP[symbol]
    end
  end

  class BoardDecorator < SimpleDelegator
    def nearby(row, column)
      {
        nw: cell(row - 1, column - 1),
        n:  cell(row - 1, column),
        w:  cell(row, column - 1),
        c:  cell(row, column)
      }
    end

    def cell(*args)
      CellDecorator.new(super(*args))
    end

    def crossroads(row)
      Array.new(width + 1) do |column|
        nearby(row, column).values_at(:nw, :n, :w, :c)
      end
    end

    def horizontal_intersecs(row)
      Array.new(width) do |column|
        nearby(row, column).values_at(:n, :n, :c, :c)
      end
    end

    def vertical_intersecs(row)
      Array.new(width + 1) do |column|
        nearby(row, column).values_at(:w, :c, :w, :c)
      end
    end
  end

  def initialize(board, color: false)
    @board = BoardDecorator.new(board)
    @color = color
  end

  def print
    separators = Array.new(@board.height.succ) { |row| print_separator(row) }
    cells = Array.new(@board.height) { |row| print_cells(row) }

    separators.zip(cells).flatten.compact
  end

  private

  def print_separator(row)
    crossroads = @board.crossroads(row).map(&method(:separator_for))
    intersects =
      @board
      .horizontal_intersecs(row)
      .map(&method(:separator_for))
      .map { |sep| sep * 3 }

    crossroads.zip(intersects).flatten.compact.join
  end

  def print_cells(row)
    intersects = @board.vertical_intersecs(row).map(&method(:separator_for))
    cells = Array.new(@board.width) { |column| print_cell @board.cell(row, column) }

    intersects.zip(cells).flatten.compact.join
  end

  def print_cell(cell)
    if @color && cell.piece && cell.piece != @board.__getobj__
      " \e[32m#{cell.unicode_symbol}\e[0m "
    else
      " #{cell.unicode_symbol} "
    end
  end

  def separator_for(intersect)
    pieces = intersect.map(&:piece)
    key =
      pieces[1..3]
      .map { |piece| pieces.uniq.index(piece) }
      .join

    SEPARATOR_MAP[key]
  end
end
