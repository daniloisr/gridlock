require 'grid'
require 'matrix'

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
    end

    def filled?(index)
      cell = self[*index]
      cell.symbol && cell.filled
    end

    def can_add?(index, piece)
      piece.cells_index.all? do |piece_index|
        board_index = (Vector[*index] + Vector[*piece_index])
        match = piece[*piece_index].symbol == self[*board_index].symbol

        !self[*board_index].filled && match
      end
    end

    def add(index, piece)
      dup.tap do |new_board|
        piece.cells_index.each do |piece_index|
          board_index = (Vector[*index] + Vector[*piece_index])
          new_board[*board_index].filled = true
          new_board[*board_index].filled_with = piece
        end
      end
    end
  end

  class Piece < SimpleDelegator
    include CellsIndexCalculator

    attr_accessor :pivot, :root

    def initialize(piece, root = nil, turns = 0)
      super(piece)

      @root = [root, piece].compact.first
      @turns = turns
      @pivot = [0, 0]
    end

    def [](x, y)
      translated = Vector[x, y] + Vector[*@pivot]
      super *translated.to_a
    end

    def rotations
      init_rotations.each_with_index do |rotation, turns|
        pivot = [0, 0]
        cells_index.map do |(x, y)|
          new_x, new_y = rotate(x, y, turns).to_a
          rotation[new_x, new_y].symbol = self[x, y].symbol

          if self[x, y].symbol
            px, py = pivot
            pivot = [new_x, new_y] if new_x < px || (new_x <= px && new_y < py)
          end
        end

        rotation.pivot = pivot
      end
    end

    def cells_index
      super.
        map {|index| rotate(*index, @turns) - Vector[*@pivot] }.
        map(&:to_a).
        select {|index| self[*index].symbol }
    end

    def to_s
      cells_index.map do |index|
        piece = self[*index]
        format("%s(%s) t%s", piece.symbol, index * ?,, @turns)
      end.join(', ')
    end

    private

    def init_rotations
      4.times.map do |turns|
        self.class.new(::Piece.new(width, symbols), self, turns)
      end
    end

    def rotate(x, y, turns)
      Vector[*(Complex(x, y) * (Complex(0, 1) ** turns)).rect]
    end
  end

  def self.solve(board, pieces)
    board = Board.new(board)
    pieces = pieces.map(&Piece.method(:new))

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
