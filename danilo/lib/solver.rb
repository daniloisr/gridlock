require 'point'
require 'grid'

class Solver
  module CellsIndexCalculator
    def cells_index
      (0...height).flat_map do |h|
        Array.new(width) { |w| [h, w] }
      end
    end
  end

  class BoardSolver < SimpleDelegator
    include CellsIndexCalculator

    def initialize(board)
      super(board)
    end

    def filled?(index)
      c = cell *index
      c.symbol && c.piece
    end

    def can_add?(index, piece)
      piece.cells_index.all? do |piece_index|
        board_index = Point.new(*index) + Point.new(*piece_index)
        match = piece.cell(*piece_index).symbol == cell(board_index.x, board_index.y).symbol

        !cell(board_index.x, board_index.y).piece && match
      end
    end

    def add(index, piece)
      dup.tap do |new_board|
        piece.cells_index.each do |piece_index|
          board_index = Point.new(*index) + Point.new(*piece_index)
          new_board.cell(board_index.x, board_index.y).piece = piece
        end
      end
    end
  end

  class PieceSolver < SimpleDelegator
    include CellsIndexCalculator

    attr_accessor :pivot, :root

    def initialize(piece, root = nil, turns = 0)
      super(piece)

      @root = [root, piece].compact.first
      @turns = turns
      @pivot = [0, 0]
    end

    def cell(x, y)
      translated = Point.new(x, y) + Point.new(*@pivot)
      super translated.x, translated.y
    end

    def rotations
      init_rotations.each_with_index do |rotation, turns|
        pivot = [0, 0]
        cells_index.map do |(x, y)|
          point = rotate(x, y, turns)
          rotation.cell(point.x, point.y).symbol = cell(x, y).symbol

          if cell(x, y).symbol
            px, py = pivot
            pivot = [point.x, point.y] if point.x < px || (point.x <= px && point.y < py)
          end
        end

        rotation.pivot = pivot
      end
    end

    def cells_index
      super
        .map { |index| rotate(*index, @turns) - Point.new(*@pivot) }
        .select { |point| cell(point.x, point.y).symbol }
        .map { |point| [point.x, point.y] }
    end

    def to_s
      cells_index.map do |index|
        piece = self[*index]
        format('%s(%s) t%s', piece.symbol, index * ',', @turns)
      end.join(', ')
    end

    private

    def init_rotations
      Array.new(4) do |turns|
        self.class.new(::Piece.new(width, symbols), self, turns)
      end
    end

    def rotate(x, y, turns)
      Point.new(*(Complex(x, y) * (Complex(0, 1)**turns)).rect)
    end
  end

  def self.solve(board, pieces)
    board = BoardSolver.new(board)
    pieces = pieces.map(&PieceSolver.method(:new))

    solve_recur(board, pieces, board.cells_index)
  end

  def self.solve_recur(board, pieces, (index, *next_indexes))
    return { solved: true, board: board } if index.nil? || pieces.empty?

    if board.filled?(index)
      return solve_recur(board, pieces, next_indexes)
    end

    pieces.each do |piece|
      piece.rotations.each do |rotated|
        if board.can_add?(index, rotated)
          recur_result = solve_recur(board.add(index, rotated), pieces - [piece], next_indexes)
          return recur_result.merge(pieces: pieces) if recur_result[:solved]
        end
      end
    end

    return { solved: false, board: [] }
  end

  private_class_method :solve_recur
end
