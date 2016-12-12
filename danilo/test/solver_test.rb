require 'minitest/autorun'
require 'grid'
require 'solver'
require 'byebug'

class TestSolver < Minitest::Test
  define_method :b, &Board.method(:new)
  define_method :p, &Piece.method(:new)

  def test_simple
    grid = <<~GRID.gsub("\n",'')
      TOXO
      TOXX
    GRID
    board = b(4, symbols: grid)

    pieces = []
    pieces << p(2, symbols: 'TO')
    pieces << p(2, symbols: 'TO')
    pieces << p(2, symbols: 'XX')
    pieces << p(2, symbols: 'XO')

    assert Solver.solve(board, pieces)[:solved]
  end

  def test_rotation
    piece = Solver::Piece.new(Piece.new(2, 'abc'))
    to_h = -> (piece) {
      piece.
        cells_index.
        select {|index| piece[*index].symbol }.
        map {|index| [piece[*index].symbol.to_sym, index] }.
        to_h
    }

    expected_rotations = [
      { a: [0, 0], b: [0, 1], c: [1, 0] },
      { a: [1, 0], b: [0, 0], c: [1, 1] },
      { a: [1, 0], b: [1,-1], c: [0, 0] },
      { a: [0, 1], b: [1, 1], c: [0, 0] },
    ]

    expected_rotations.each_with_index do |expected_rotation, turn|
      assert_equal expected_rotation, to_h.(piece.rotations[turn]), "Rotation #{turn} failed"
    end
  end

  def test_can_add
    board = Solver::Board.new(Board.new(2, 'abba'))
    piece = Solver::Piece.new(Piece.new(2, 'ab'))

    assert board.can_add?([0, 0], piece)
    refute board.can_add?([0, 1], piece)
    assert board.can_add?([0, 0], piece.rotations[3])

    piece = Solver::Piece.new(Piece.new(2, 'abb'))
    assert board.can_add?([0, 0], piece)
    refute board.can_add?([0, 1], piece)
    assert board.can_add?([0, 1], piece.rotations[2])
  end

  def test_add
    board = Solver::Board.new(Board.new(2, 'abba'))
    piece = Solver::Piece.new(Piece.new(2, 'ab'))

    new_board = board.add([0, 0], piece)
    assert_equal [true, true, nil, nil], new_board.cells_index.map {|i| new_board[*i].filled }

    piece = Solver::Piece.new(Piece.new(2, 'abb'))
    new_board = board.add([0, 0], piece)
    assert_equal [true, true, true, nil], new_board.cells_index.map {|i| new_board[*i].filled }
  end

  def test_single_piece
    assert Solver.solve(b(2, 'TO'), [p(2, 'TO')])[:solved]
    assert Solver.solve(b(1, 'TO'), [p(2, 'TO')])[:solved]
    assert Solver.solve(b(2, 'TO'), [p(2, 'OT')])[:solved]
    assert Solver.solve(b(1, 'TO'), [p(2, 'OT')])[:solved]

    refute Solver.solve(b(2, 'TO'), [p(2, 'TX')])[:solved]
  end

  def test_simple_rotation
    grid = <<~GRID.gsub("\n",'')
      TOX
      TOX
    GRID
    board = b(3, grid)

    pieces = []
    pieces << p(2, 'OX')
    pieces << p(2, 'TT')
    pieces << p(2, 'OX')

    assert Solver.solve(board, pieces)[:solved]
  end

  def test_left_insert
    board = b(2, 'TO')
    pieces = [p(2, 'OT')]

    assert Solver.solve(board, pieces)[:solved]
  end

  def test_board_side_limits
    grid = <<~GRID.gsub("\n",'')
      TOX
      TOX
    GRID
    board = b(3, grid)

    pieces = []
    pieces << p(2, 'OX')
    pieces << p(2, 'TO')
    pieces << p(2, 'TX')

    refute Solver.solve(board, pieces)[:solved]
  end

  def test_board_up_down_limits
    grid = <<~GRID.gsub("\n",'')
      TO
      OX
      XX
    GRID
    board = b(2, grid)

    pieces = []
    pieces << p(2, 'TX')
    pieces << p(2, 'OX')
    pieces << p(2, 'OX')

    # byebug
    refute Solver.solve(board, pieces)[:solved]
    return

    pieces = []
    pieces << p(2, 'XT')
    pieces << p(2, 'OX')
    pieces << p(2, 'XO')

    refute Solver.solve(board, pieces)[:solved]
  end

  def test_2d_piece
    grid = b(2, 'TOT')
    pieces = [p(2, 'TOT')]

    assert Solver.solve(grid, pieces)
  end

  def test_2d_pieces
    grid = <<~GRID.gsub("\n",'')
      TOXO
      TOXX
    GRID
    board = b(4, grid)

    pieces = []
    pieces << p(2, 'TOT')
    pieces << p(2, 'OXX')
    pieces << p(2,  'OX')

    assert Solver.solve(board, pieces)
  end

  def test_mid_grid
    grid = <<~GRID.gsub("\n",'')
      TXOO
      OTTX
      XXOX
    GRID
    board = b(4, grid)

    a = 'TXO'
    b = 'OO'
    c = 'TT'
    d = 'XOX'
    f = 'XX'

    pieces = [f,d,a,c,b].map {|i| p(2, i)}

    assert Solver.solve(board, pieces)
  end

  def test_real_case
    grid = <<~GRID.gsub("\n",'')
      TXOO
      OTTX
      XXOX
      XTOT
      XTXX
      OTOO
      OOTT
    GRID
    board = b(4, grid)

    a = 'XO'
    b = 'XT'
    c = 'TO'
    d = 'XX'
    f = 'OO'
    g = 'TOT'
    i = 'OTX'
    j = 'XXT'
    k = 'OOT'

    pieces = [a,a,b,b,c,c,d,f,g,i,j,k].map {|i| p(2, i)}

    assert Solver.solve(board, pieces)
  end
end

