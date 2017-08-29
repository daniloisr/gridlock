require 'minitest/autorun'
require 'byebug'

require_relative './solver.rb'

class SolverTest < Minitest::Test
  def setup
    @board = new_grid(<<~BOARD)
      o x
      x x
    BOARD
  end

  def test_create_columns
    root = create_columns(@board, [])
    names = walk(root, skip: true).map { |cell| cell[:n] }
    assert_equal 'oxxx', names.join
  end

  def test_piece_matches_1
    piece = new_grid('x o')
    matches = find_matches(@board, piece)
    assert_equal [[0, 1], [0, 2]], matches
  end

  def test_piece_matches_2
    piece = new_grid('x x')
    matches = find_matches(@board, piece)
    assert_equal [[1, 3], [2, 3]], matches
  end

  def test_matrix
    root = create_solve_matrix(@board, [new_grid('o x'), new_grid('x x')])
    solution_matrix = <<~MATRIX.chomp
      1 2 O X X X
      x . x x . .
      x . x . x .
      . x . x . x
      . x . . x x
    MATRIX

    assert_equal solution_matrix, print_matrix(root)
  end

  def test_first_step
    root = create_solve_matrix(@board, [new_grid('o x'), new_grid('x x')])
    first_column = walk(root, skip: 1)[0]
    removed = search(root)
    solution_matrix = <<~MATRIX.chomp
      2 X X
      x x x
    MATRIX

    assert_equal removed[0], first_column
    assert_equal solution_matrix, print_matrix(root)
  end
end
