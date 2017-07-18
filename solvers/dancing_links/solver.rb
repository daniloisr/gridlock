# require 'rotator'

class DoublyLinkedList
  attr_accessor :val, :pred, :succ

  def initialize(val, pred: self, succ: self)
    @val = val
    @pred = pred
    @succ = succ
  end

  # @param item [DoublyLinkedList] the item to be added at end of this list
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
end

class SolverCell
  # def initialize
  # end
end

board_width = 2
board = 'TXOX'

# insertion
# @todo move to method
header, *tail = board.chars.map(&DoublyLinkedList.method(:new))
tail.each(&header.method(:add))

# print
# @todo move to method
count = 0
current = header
# @todo create an iterator method for DoublyLinkedList
loop do
  count = (count + 1) % board_width
  print current.val + count.zero? ? "\n" : ' '
  break if (current = current.succ) == header
end

# @todo try to print this Solution Matrix
# # Board:
#     T X
#     X X
#
# # Pieces
#     [T X], [X X]
#
# # Solution Matrix
#
#     T X X X Header
#     ------- TX piece
#     1 1 0 0 |
#     1 0 1 0 |
#     ------- XX piece
#     0 1 0 1 |
#     0 0 1 1 |

# setup header
def build_header(board); end
board = 'xo xo'
header = build_header(board)

# setup a single piece
piece = 'xo'
piece_solutions = [[0, 2], [1, 3]]
piece_cells = []
piece_ref = Cell.new(piece)
class Cell
  attr_reader :hlist, :vlist
  def initialize(ref)
    @ref = ref
    @hlist = DoublyLinkedList.new
    @vlist = DoublyLinkedList.new
  end
end

# build the solution matrix
current = header
index = 0
loop do
  piece_solutions.each do |solution|
    if solution.include?(index)
      current.vertical_list.add(build_piece(piece))
    end
  end

  index += 1
  break if (current = current.succ) == header
end
