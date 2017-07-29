# require 'rotator'
require 'byebug'

class DblList
  include Enumerable

  attr_accessor :val, :pred, :succ

  def initialize(val)
    @val = val
    @pred = self
    @succ = self
  end

  # @param item [DblList] the item to be added at end of this list
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

  # @yield [DblList] each node of the list
  def each(&block)
    p = self
    loop do
      yield p
      break if (p = p.succ) == self
    end
  end

  # @param index [Integer]
  # @return [DblList] element at
  def [](index)
    index.zero? ? self : succ[index - 1]
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

# Keep track of piece solution in the grid
# It is used to remove piece's solutions from the grid
class PieceSolution
  attr_reader :piece, :solutions

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

module Node
  attr_reader :row, :column

  def init_lists
    @row = DblList.new(self)
    @column = DblList.new(self)
  end

  # @todo drop the call to `.val` from the next methods
  def lt
    @row.succ.val
  end

  def rg
    @row.pred.val
  end

  def up
    @column.pred.val
  end

  def dn
    @column.succ.val
  end

  # Add node to the bottom of column
  #
  # @param [Node]
  def add_to_column(node)
    @column.add(node.column)
  end

  # Add node to the end of row
  #
  # @param [Node]
  def add_to_row(node)
    @row.add(node.row)
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
  include Node

  attr_reader :piece_solution, :head

  def initialize(piece_solution, head)
    @piece_solution = piece_solution
    @head = head
    init_lists

    # link solution cell with the header row
    head.add_to_column(self)
  end
end

class HeaderCell
  include Node

  attr_reader :symbol, :size

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
    # @todo using .val here is confusing
    @row[index].val
  end

  # Add node to the end of column and increment size
  #
  # @param (see Node#add_to_column)
  def add_to_column(node)
    super(node)
    @size += 1
  end

  def print_row(stop = nil)
    return symbol.to_s if rg == stop
    format('%s %s', symbol, rg.print_row(stop ? stop : self))
  end
end

# setup header
def main
  board = [2, 'oxxx']
  header_ref, current_ref = nil

  board[1].each_char do |symbol|
    new_ref = HeaderCell.new(symbol)

    current_ref&.add_to_row(new_ref)
    current_ref = new_ref
    header_ref = current_ref unless header_ref
  end

  pieces = [[2, 'xo'], [2, 'xx']]
  piece_solutions = pieces.each_with_index.map do |piece, index|
    # @todo generate board-fit for each piece...
    hard_coded_fits =
      case index
      when 0
        [[0, 1], [0, 2]]
      when 1
        [[1, 3], [2, 3]]
      end

    PieceSolution.new(piece).tap do |piece_solution|
      # @todo move to a method
      hard_coded_fits.each do |positions|
        solution_node = nil

        positions.each do |column_index|
          # init new node for solution
          new_solution_node = PieceNode.new(piece_solution, header_ref[column_index])
          if solution_node
            # add the new solution ref to the end of solution row
            solution_node.add_to_row(new_solution_node)
          else
            # for the first node solution_node will be nil and we assign it
            solution_node = new_solution_node unless solution_node
          end
        end

        # piece_solution will point to all solution_nodes
        piece_solution << solution_node
      end
    end
  end

  # # Solution Matrix
  #
  #     O X X X Header
  #     ------- OX piece
  #     1 1 0 0 |
  #     1 0 1 0 |
  #     ------- XX piece
  #     0 1 0 1 |
  #     0 0 1 1 |
  puts "#{header_ref.print_row.upcase} HEADER"

  piece_solution = piece_solutions.first
  puts "------- #{piece_solution.piece[1].upcase} piece"

  heads = piece_solution.solutions.first.row.to_a.map(&:val).map(&:head)
  puts header_ref.row.to_a.map {|i| heads.include?(i.val) ? 'x' : '.' }.join(' ')

  heads = piece_solution.solutions[1].row.to_a.map(&:val).map(&:head)
  puts header_ref.row.to_a.map {|i| heads.include?(i.val) ? 'x' : '.' }.join(' ')

  piece_solution = piece_solutions[1]
  puts "------- #{piece_solution.piece[1].upcase} piece"

  heads = piece_solution.solutions.first.row.to_a.map(&:val).map(&:head)
  puts header_ref.row.to_a.map {|i| heads.include?(i.val) ? 'x' : '.' }.join(' ')

  heads = piece_solution.solutions[1].row.to_a.map(&:val).map(&:head)
  puts header_ref.row.to_a.map {|i| heads.include?(i.val) ? 'x' : '.' }.join(' ')
end

main
