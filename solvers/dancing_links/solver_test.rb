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

  def test_clone
    root = create_solve_matrix(new_grid('o x'), [new_grid('o x')])
    cloned = clone(root)

    assert_equal print_matrix(root), print_matrix(cloned)
  end

  # @todo add a way to stop search in the middle of the proccess
  def test_first_step
    skip 'There is no more "first_step", but it would be useful...'
    root = create_solve_matrix(@board, [new_grid('o x'), new_grid('x x')])
    ref_root = clone(root)
    first_column = walk(root, skip: 1)[0]
    removed = search(root)
    # @todo improve variable declarion on this test
    solution_matrix = <<~MATRIX.chomp
      2 X X
      x x x
    MATRIX

    assert_equal removed[0], first_column
    assert_equal solution_matrix, print_matrix(root, ref_root)
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
    pretty = ->((node, index)) { [debug_node(node), index] }

    # @todo failing test is impossible to read, should use a better struct
    #       instead of a hash and print it using a method like 'debug_node'
    #       Parsing the results before comparing (temporary)...
    assert_equal expected.map(&pretty), result.map(&pretty)
  end

  def test_search_no_solution
    root = create_solve_matrix(new_grid('o x'), [new_grid('x x')])
    assert_equal [], search(root)[:result]
  end

  def test_uncover
    el1 = create_el
    el2 = create_el(u: el1, d: el1)
    el3 = create_el
    el4 = create_el(l: el1, r: el1)
    link(el2, el3)
    link(el4, el3, :u, :d)
    uncover(el4)

    assert_equal el1[:r].object_id, el4.object_id
    assert_equal el1[:l].object_id, el4.object_id
    assert_equal el1[:u].object_id, el2.object_id
    assert_equal el1[:d].object_id, el2.object_id
  end
end
