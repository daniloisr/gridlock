require 'byebug'
require 'minitest/autorun'
require 'printer'
require 'solver'

class PrinterTest < Minitest::Test
  def test_print_single_cell
    board = Board.new(1, 'T')
    board.cell(0, 0).piece = Piece.new(1, 'T')

    printer = Printer.new(board)
    expected = [
      '┌───┐',
      '│ ■ │',
      '└───┘'
    ]

    assert_equal expected, printer.print

    printer = Printer.new(board, color: true)
    expected = [
      '┌───┐',
      "│ \e[32m■\e[0m │",
      '└───┘'
    ]

    assert_equal expected, printer.print
  end

  def test_print_multiple_cells
    board = Board.new(3, 'TOOXTOXO')
    pieces = []
    pieces << Piece.new(1, 'T')
    pieces << Piece.new(1, 'T')
    pieces << Piece.new(1, 'O')
    pieces << Piece.new(2, 'OOO')
    pieces << Piece.new(2, 'XX')

    board = Solver.solve(board, pieces)[:board]

    # TODO: add a parameter to print without colors
    assert_equal Printer.new(board).print, [
      '┌───┬───────┐',
      "│ ■ │ ●   ● │",
      '├───┼───┐   │',
      "│ ✚ │ ■ │ ● │",
      '│   ├───┼───┘',
      "│ ✚ │ ● │    ",
      '└───┴───┘    '
    ]
  end
end
