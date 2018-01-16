require 'minitest/autorun'
require 'byebug'

require_relative './solver.rb'

class SolverTest < Minitest::Test
  include DancingLinks

  def simple_board
    @simple_board ||= grid(<<~BOARD)
      o x
      x x
    BOARD
  end

  def test_create_columns
    root = create_columns(simple_board, [])
    names = walk(root, skip: true).map(&:name)
    assert_equal 'oxxx', names.join
  end

  def test_piece_matches_1
    piece = piece('x o')
    matches = find_matches(simple_board, piece)
    assert_equal [[[0, 1], 2], [[0, 2], 1]], matches
  end

  def test_piece_matches_2
    piece = piece('x x')
    matches = find_matches(simple_board, piece)
    assert_equal [[[1, 3], 3], [[2, 3], 0]], matches
  end

  def test_matrix
    root = create_solve_matrix(simple_board, [piece('o x'), piece('x x')])
    solution_matrix = <<~MATRIX.chomp
      1 2 O X X X
      x . x x . .
      x . x . x .
      . x . x . x
      . x . . x x
    MATRIX

    assert_equal 2, root.r.size
    assert_equal solution_matrix, print_matrix(root)
  end

  def test_search_single_piece
    root = create_solve_matrix(grid('o x'), [piece('o x')])
    assert_equal [root.r.d], search(root)
  end

  def test_search_two_pieces
    pieces = [piece('o x'), piece('x x')]
    root = create_solve_matrix(simple_board, pieces)
    expected = [root.r.d, root.r.r.d.d]
    result = search(root)

    assert result
    assert_equal expected, result
  end

  # Matrix:
  # 1 2 3 X X T X X O
  # x . . x x . . . .
  # x . . x . . x . .
  # x . . . x . . x .
  # x . . . . . x x .
  # . x . . . . . x x
  # . . x . x x . . .
  def test_search_three_pieces
    root = create_solve_matrix(
      grid("x x t\nx x o"),
      [piece('x x'), piece('o x'), piece('x t')]
    )
    expected = [root.r.r.d, root.r.r.r.d, root.r.d.d]
    result = search(root)

    assert result
    assert_equal expected.map(&:id), result.map(&:id)
    assert_equal [2, 0, 3], result.map(&:rotation)
  end

  def test_search_no_solution
    root = create_solve_matrix(grid('o x'), [piece('x x')])
    assert_equal false, search(root)
  end

  # Matrix:
  #
  #   1 2 O X X X
  #   x . x x . .
  #   x . x . x .
  #   . x . x . x
  #   . x . . x x
  #
  # Piece covered: 1, second row
  #
  #   2 X X
  #   x x x
  #
  def test_cover
    root = create_solve_matrix(simple_board, [piece('o x'), piece('x x')])
    cover(root.r.d.d)

    assert_equal [1, 1, 1], walk(root, skip: 1).map(&:size)
    assert_equal <<~MATRIX.chomp, print_matrix(root)
      2 X X
      x x x
    MATRIX
  end

  # Matrix:
  #
  #   1 2 O X X X
  #   x . x x . .
  #   x . x . x .
  #   . x . x . x
  #   . x . . x x
  #
  def test_uncover
    root = create_solve_matrix(simple_board, [piece('o x'), piece('x x')])
    row = root.r.d.d

    cover(row)
    uncover(row)

    assert_equal [2, 2, 2, 2, 2, 2], walk(root, skip: 1).map(&:size)

    assert_equal <<~MATRIX.chomp, print_matrix(root)
      1 2 O X X X
      x . x x . .
      x . x . x .
      . x . x . x
      . x . . x x
    MATRIX
  end
end
