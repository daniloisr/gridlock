require 'delegate'
require 'point'
require 'grid'

class Solver
  module CellsIndexCalculator
    def cells_index
      (0...height)
        .flat_map { |h| Array.new(width) { |w| Point.new h, w } }
    end
  end

  class BoardSolver < SimpleDelegator
    include CellsIndexCalculator

    def initialize(board)
      super(board)
    end

    def filled?(index)
      c = cell(index)
      c.symbol && !c.piece_id.nil?
    end

    def can_add?(index, piece)
      index = Point.new(index) if index.is_a?(Array)

      piece.cells_index.all? do |piece_index|
        board_index = index + piece_index
        match = piece.cell(piece_index).symbol == cell(board_index).symbol

        cell(board_index).piece_id.nil? && match
      end
    end

    def add(index, piece)
      index = Point.new(index) if index.is_a?(Array)

      clone.tap do |new_board|
        piece.cells_index.each do |piece_index|
          board_index = index + piece_index
          new_board.cell(board_index).piece_id = piece.id
        end
      end
    end
  end

  class PieceSolver < SimpleDelegator
    include CellsIndexCalculator

    attr_accessor :pivot, :root, :turns

    def initialize(piece, root = nil, turns = 0)
      super(piece)

      @root = root || piece
      @turns = turns
      @pivot = Point.new(0, 0)
    end

    def cell(*args)
      point = args.size == 2 ? Point.new(*args) : args.first
      super point + pivot
    end

    def rotations
      init_rotations.each_with_index do |rotation, turns|
        pivot = Point.new(0, 0)

        cells_index
          .each do |point|
            rotated_point = point.rotate(turns)
            rotation.cell(rotated_point).symbol = cell(point).symbol

            pivot = rotated_point if cell(point).symbol && rotated_point < pivot
          end

        rotation.pivot = pivot
      end
    end

    def cells_index
      super
        .map { |point| point.rotate(turns) - pivot }
        .select { |point| cell(point).symbol }
    end

    private

    def init_rotations
      Array.new(4) do |turns|
        self.class.new(clone, self, turns)
      end
    end
  end

  def self.solve(board, pieces)
    board = BoardSolver.new(board)
    pieces = pieces.map(&PieceSolver.method(:new))

    solve_recur(board, pieces, board.cells_index)
  end

  def self.solve_recur(board, pieces, (index, *next_indexes))
    return { solved: true, board: board } if index.nil? || pieces.empty?
    return solve_recur(board, pieces, next_indexes) if board.filled?(index)

    pieces.each do |piece|
      piece.rotations.each do |rotated|
        if board.can_add?(index, rotated)
          recur_result = solve_recur(board.add(index, rotated), pieces - [piece], next_indexes)
          return recur_result.merge(pieces: pieces) if recur_result[:solved]
        end
      end
    end

    { solved: false, board: [] }
  end

  private_class_method :solve_recur
end
