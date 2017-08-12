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

  def test_setup_header
    header = setup_header(@board)
    names = row_cells(header).map { |cell| cell[:n] }
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
    game = {}
    game[:board] = @board
    game[:header] = setup_header(game[:board])
    game[:hrefs]  = hrefs = row_cells(game[:header]).to_a

    # create linked list for 'piece' at 'matches' positions
    game[:pieces] = [new_grid('o x'), new_grid('x x')]
    game[:solutions] = create_solutions(game)

    # # Solution Matrix
    solution_matrix = <<~MATRIX.chomp
      1 2 O X X X
      x . x x . .
      x . x . x .
      . x . x . x
      . x . . x x
    MATRIX

    print_matrix = []
    print_matrix << (1..game[:solutions].size).to_a.join(' ') + ' ' + hrefs.map { |p| p[:n] }.join(' ').upcase

    game[:solutions].each do |solution|
      _piece, srows = solution

      srows.each do |ref|
        prefs = row_cells(ref).map { |r| r[:c] }
        piece_prefix = game[:solutions].map { |s| s == solution ? 'x' : '.' }.join(' ')
        print_matrix << piece_prefix + ' ' + hrefs.map { |href| prefs.include?(href) ? 'x' : '.' }.join(' ')
      end
    end

    assert_equal solution_matrix, print_matrix.join("\n")
  end
end
