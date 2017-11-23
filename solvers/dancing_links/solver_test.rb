require 'minitest/autorun'
require 'byebug'

require_relative './solver.rb'

class SolverTest < Minitest::Test
  include DancingLinks

  def setup
    @board = new_grid(<<~BOARD)
      o x
      x x
    BOARD
  end

  def test_create_columns
    root = create_columns(@board, [])
    names = walk(root, skip: true).map { |cell| cell.name }
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

  def test_search_single_piece
    root = create_solve_matrix(new_grid('o x'), [new_grid('o x')])
    assert_equal [[root[:r], 0]], search(root)[:result]
  end

  def test_search_two_pieces
    pieces = [new_grid('o x'), new_grid('t x')]
    root = create_solve_matrix(new_grid("o x\nt x"), pieces)
    expected = [
      [root[:r],     0],
      [root[:r][:r], 0]
    ]
    result = search(root)[:result]
    pretty = ->((node, index)) { [node.inspect, index] }

    assert_equal expected.map(&pretty), result.map(&pretty)
  end

  def test_search_no_solution
    root = create_solve_matrix(new_grid('o x'), [new_grid('x x')])
    assert_equal [], search(root)[:result]
  end

  # matrix:
  #   el4 is uncovered with el1
  #
  #     el1    el4
  #      |      |
  #   > el2 <> el3 <
  #
  def test_uncover
    # @todo use a "create_solve_matrix" and "cover" to setup this test
    el1 = Node.new
    el2 = Node.new(u: el1, d: el1)
    el3 = Node.new
    el4 = Node.new(l: el1, r: el1)
    link(el2, el3)
    link(el4, el3, :u, :d)
    uncover(el4)

    assert_equal el1[:r].object_id, el4.object_id
    assert_equal el1[:l].object_id, el4.object_id
    assert_equal el1[:u].object_id, el2.object_id
    assert_equal el1[:d].object_id, el2.object_id
  end
end
