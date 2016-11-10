require 'byebug'
require 'minitest/autorun'
require 'printer'

class PrinterTest < Minitest::Test
  def test_print_single_cell
    byebug
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
