require 'minitest/autorun'
require 'grid'
require 'matrix'
# require 'solver'
require 'byebug'

class Solver
  module CellsIndexCalculator
    def cells_index
      height.times.flat_map {|h| width.times.map {|w| [h, w] } }
    end
  end

  class Board < SimpleDelegator
    include CellsIndexCalculator

    def initialize(board)
      super(board)
      @filled = Hash.new(false)
    end

    def filled?(index)
      cell = self[*index]
      cell.symbol && @filled[index]
    end
  end

  class Piece < SimpleDelegator
    include CellsIndexCalculator

    attr_accessor :pivot

    def initialize(piece, root = nil, turns = 0)
      super(piece)

      @root = [root, piece].compact.first
      @turns = turns
      @pivot = [0, 0]
    end

    def [](x, y)
      translated = rotate(x, y, @turns) - Vector[*@pivot]
      super *translated.to_a
    end

    def rotations
      init_rotations.each_with_index do |rotated, turns|
        pivot = [0, 0]
        cells_index.map do |(x, y)|
          new_x, new_y = rotate(x, y, turns).to_a
          rotated[new_x, new_y].symbol = self[x, y].symbol

          if self[x, y].symbol
            px, py = pivot
            pivot = [new_x, new_y] if new_x < px || (new_x <= px && new_y < py)
          end
        end

        rotated.pivot = pivot
      end
    end

    def rotate(x, y, turns)
      Vector[*(Complex(x, y) * (Complex(0, 1) ** turns)).rect]
    end

    def cells_index
      super.map {|index| rotate(*index, @turns) - Vector[*@pivot] }.map(&:to_a)
    end

    private

    def init_rotations
      4.times.map do |turns|
        new_width = turns.even? ? width : height
        self.class.new(::Piece.new(new_width, symbols), self, turns)
      end
    end
  end

  def self.solve(board, pieces)
    board = BoardSolver.new(board)
    pieces = pieces.map(&PieceSolver.method(:new))

    solve_recur(board, pieces, [], board.cells_index)
  end

  private

  def self.solve_recur(board, pieces, (cur_index, *next_indexes))
    return { solved: true, solution: board } if index_list.empty? || pieces.empty?

    if board.filled?(cur_index)
      return solve_recur(board, pieces, next_indexes)
    end

    pieces.each do |piece|
      piece.rotations.each do |rotated|
        if board.can_add?(cur_index, rotated)
          recur_result = solve_recur(board.add(rotated), pieces - piece, next_indexes)
          return recur_result if recur_result[:solved]
        end
      end
    end

    return { solved: false, solution: [] }
  end
end

class TestSolver < Minitest::Test
  define_method :b, &Board.method(:new)
  define_method :p, &Piece.method(:new)

  def test_rotation
    piece = Solver::Piece.new(Piece.new(2, 'abc'))
    piece.rotations
    byebug
  end

  def test_single_piece
    skip
    assert_equal [true, [[0, 0, 0]]], Solver.solve(b(2, 'TO'), [[2, 'TO', true]])
    assert_equal [true, [[0, 0, 1]]], Solver.solve(b(1, 'TO'), [[2, 'TO', true]])
    assert_equal [true, [[1, 0, 2]]], Solver.solve(b(2, 'TO'), [[2, 'OT', true]])
    assert_equal [true, [[1, 0, 3]]], Solver.solve(b(1, 'TO'), [[2, 'OT', true]])
  end

  def test_simple
    skip
    grid = <<~GRID.gsub("\n",'')
      TOXO
      TOXX
    GRID
    grid = [4, grid]

    pieces = []
    pieces << [2, 'TO', true]
    pieces << [2, 'TO', true]
    pieces << [2, 'XX', true]
    pieces << [2, 'XO', true]

    assert_equal Solver.solve(grid, pieces),
      [true, [[0, 0, 0], [2, 2, 1], [4, 1, 0], [7, 3, 3]]]
  end

  def test_simple_rotation
    skip
    grid = <<~GRID.gsub("\n",'')
      TOX
      TOX
    GRID
    grid = [3, grid]

    pieces = []
    pieces << [2, 'OX']
    pieces << [2, 'TT']
    pieces << [2, 'OX']

    assert Solver.solve(grid, pieces)
  end

  def test_left_insert
    skip
    grid = [2, 'TO']
    pieces = [[2, 'OT']]

    assert Solver.solve(grid, pieces)
  end

  def test_board_side_limits
    skip
    grid = <<~GRID.gsub("\n",'')
      TOX
      TOX
    GRID
    grid = [3, grid]

    pieces = []
    pieces << [2, 'OX']
    pieces << [2, 'TO']
    pieces << [2, 'TX']

    refute Solver.solve(grid, pieces)
  end

  def test_board_up_down_limits
    skip
    grid = <<~GRID.gsub("\n",'')
      TO
      OX
      XX
    GRID
    grid = [2, grid]

    pieces = []
    pieces << [2, 'TX']
    pieces << [2, 'OX']
    pieces << [2, 'OX']

    refute Solver.solve(grid, pieces)

    pieces = []
    pieces << [2, 'XT']
    pieces << [2, 'OX']
    pieces << [2, 'XO']

    refute Solver.solve(grid, pieces)
  end

  def test_2d_piece
    skip
    grid = <<~GRID.gsub("\n",'')
      TO
      T_
    GRID
    grid = [2, grid]

    pieces = []
    pieces << [2, 'TOT']

    assert Solver.solve(grid, pieces)
  end

  def test_2d_pieces
    skip
    grid = <<~GRID.gsub("\n",'')
      TOXO
      TOXX
    GRID
    grid = [4, grid]

    pieces = []
    pieces << [2, 'TOT']
    pieces << [2, 'OXX']
    pieces << [2,  'OX']

    assert Solver.solve(grid, pieces)
  end

  def test_mid_grid
    skip
    grid = <<~GRID.gsub("\n",'')
      TXOO
      OTTX
      XXOX
    GRID
    grid = [4, grid]

    a = 'TXO'
    b = 'OO'
    c = 'TT'
    d = 'XOX'
    f = 'XX'

    pieces = [f,d,a,c,b].map {|i| [2, i]}

    assert Solver.solve(grid, pieces)
  end

  def test_real_case
    skip
    grid = <<~GRID.gsub("\n",'')
      TXOO
      OTTX
      XXOX
      XTOT
      XTXX
      OTOO
      OOTT
    GRID
    grid = [4, grid]

    a = 'XO'
    b = 'XT'
    c = 'TO'
    d = 'XX'
    f = 'OO'
    g = 'TOT'
    i = 'OTX'
    j = 'XXT'
    k = 'OOT'

    pieces = [a,a,b,b,c,c,d,f,g,i,j,k].map {|i| [2, i]}

    assert Solver.solve(grid, pieces)
  end
end

