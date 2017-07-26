# require 'rotator'
require 'byebug'
require 'forwardable'

class Node
  attr_accessor :val, :pred, :succ

  def initialize(val, pred: self, succ: self)
    @val = val
    @pred = pred
    @succ = succ
  end

  # @param item [Node] the item to be added at end of this list
  def add(item)
    # current state: pred <-> self

    # first step: update item refs
    # pred <- item -> self
    item.pred = pred
    item.succ = self

    # second step: update this list refs
    # pred -> item <- self
    pred.succ = item
    self.pred = item
  end

  # @param index [Integer]
  # @return [Node] element at
  def [](index)
    current_ref = self
    index.times { current_ref = current_ref.succ }
    current_ref
  end
end

def print
  board_width = 2
  board = 'TXOX'

  # insertion
  # @todo move to method
  header, *tail = board.chars.map(&Node.method(:new))
  tail.each(&header.method(:add))

  # print
  # @todo move to method
  count = 0
  current = header
  # @todo create an iterator method for Node
  loop do
    count = (count + 1) % board_width
    print current.val + count.zero? ? "\n" : ' '
    break if (current = current.succ) == header
  end
end

# @todo try to print this Solution Matrix
# # Board:
#     O X
#     X X
#
# # Pieces
#     [O X], [X X]
#
# # Solution Matrix
#
#     O X X X Header
#     ------- OX piece
#     1 1 0 0 |
#     1 0 1 0 |
#     ------- XX piece
#     0 1 0 1 |
#     0 0 1 1 |

# setup header
def main
  board = [2, 'oxxx']
  header_ref, current_ref = nil

  board[1].each_char do |symbol|
    new_ref = HeaderCell.new(symbol)

    current_ref&.row&.add(new_ref)
    current_ref = new_ref
    header_ref = current_ref unless header_ref
  end

  pieces = [[2, 'xo'], [2, 'xx']]
  pieces.each_with_index do |index, piece|
    piece_solutions =
      case index
      when 0
        [[0, 1], [0, 2]]
      when 1
        [[1, 3], [2, 3]]
      end

    piece_solution = PieceSolution.new(piece)
    piece_solutions.each do |positions|
      solution_node = nil

      positions.each do |column_index|
        # init new node for solution
        new_solution_node = PieceNode.new(piece_solution)
        if solution_node
          # add the new solution ref to the end of solution row
          solution_node.add_to_row(new_solution_node)
        else
          # for the first node solution_node will be nil and we assign it
          solution_node = new_solution_node unless solution_node
        end

        # link solution cell with the header row
        header_ref[column_index].add_to_column(solution_node)
      end

      # piece_solution will point to all solution_nodes
      piece_cell << solution_node
    end
  end

  header_ref.add_column
end

# Keep track of piece solution in the grid
# It is used to remove piece's solutions from the grid
class PieceSolution
  def initialize(piece)
    # @todo not sure @piece will be need
    @piece = piece
    @solutions = []
  end

  # Add a new PieceNode to the solutions array
  #
  # @param [PieceNode]
  def <<(ref)
    @solutions << ref
  end
end

module Cell
  extend Forwardable

  def init_lists
    @row = Node.new(self)
    @column = Node.new(self)
  end

  def_delegator :@row, :succ, :lt
  def_delegator :@row, :pred, :rg
  def_delegator :@column, :pred, :up
  def_delegator :@column, :succ, :dw

  # Add node to the bottom of column
  #
  # @param [Cell]
  def add_to_column(node)
    @column.add(node)
  end

  # Add node to the end of row
  #
  # @param [Cell]
  def add_to_row(node)
    @row.add(node)
  end

  def id
    object_id.to_s(36)
  end

  def lists_refs
    format(
      'lt#%s rg#%s up#%s dw#%s',
      *[lt, rg, up, dw].map { |ref| ref.val.id }
    )
  end

  def inspect
    format('<#%s %s>', id, lists_refs)
  end
end

class PieceNode
  include Cell

  def initialize(piece_ref)
    @piece_ref = piece_ref
    init_lists
  end
end

class HeaderCell
  include Cell

  def initialize(symbol)
    @symbol = symbol
    @size = 0
    init_lists
  end

  # Get horizontal nodes by index
  #
  # @param [Number] index
  # @return [HeaderCell]
  def [](index)
    @row[index]
  end

  # Add node to the end of column and increment size
  #
  # @param (see Cell#add_to_column)
  def add_to_column(node)
    super(node)
    @size += 1
  end
end

main
