require 'minitest/autorun'
require 'byebug'

require_relative './solver.rb'

class SolverTest < Minitest::Test
  include DancingLinks

  def setup
    @board = grid(<<~BOARD)
      o x
      x x
    BOARD
  end

  def test_create_columns
    root = create_columns(@board, [])
    names = walk(root, skip: true).map(&:name)
    assert_equal 'oxxx', names.join
  end

  def test_piece_matches_1
    piece = piece('x o')
    matches = find_matches(@board, piece)
    assert_equal [[[0, 1], 2], [[0, 2], 1]], matches
  end

  def test_piece_matches_2
    piece = piece('x x')
    matches = find_matches(@board, piece)
    assert_equal [[[1, 3], 3], [[2, 3], 0]], matches
  end

  def test_matrix
    root = create_solve_matrix(@board, [piece('o x'), piece('x x')])
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
    root = create_solve_matrix(@board, pieces)
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
    pieces = [piece('x x'), piece('o x'), piece('x t')]
    root = create_solve_matrix(grid("x x t\nx x o"), pieces)
    expected = [root.r.r.d, root.r.r.r.d, root.r.d.d]

    result = search(root)

    assert result
    assert_equal expected.map(&:id), result.map(&:id)
    assert_equal 2, result[0].rotation
    assert_equal 0, result[1].rotation
    assert_equal 3, result[2].rotation
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
    root = create_solve_matrix(@board, [piece('o x'), piece('x x')])
    col = root.r
    row = col.d.d

    cover(row)

    assert_equal root.r, col.r
    assert_equal root,   col.r.l
    # check the 4o column header
    assert_equal root.r.d.r.u, col.d.r.r.u

    assert_equal [1, 1, 1], walk(root, skip: 1).map(&:size)

    solution_matrix = <<~MATRIX.chomp
      2 X X
      x x x
    MATRIX

    assert_equal solution_matrix, print_matrix(root)
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
    root = create_solve_matrix(@board, [piece('o x'), piece('x x')])
    col = root.r
    row = col.d.d

    cover(row)
    uncover(row)

    assert_equal root.r, col
    assert_equal col.r.l, col
    # check the 4o column header
    assert_equal root.r.r.d.r.u, col.d.r.r

    assert_equal [2, 2, 2, 2, 2, 2], walk(root, skip: 1).map(&:size)

    solution_matrix = <<~MATRIX.chomp
      1 2 O X X X
      x . x x . .
      x . x . x .
      . x . x . x
      . x . . x x
    MATRIX

    assert_equal solution_matrix, print_matrix(root)
  end
end
