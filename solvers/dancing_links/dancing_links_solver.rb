require 'byebug'
require 'rotator'

class DoublyLinkedList
  attr_accessor :val, :lt, :rt
  def initialize(val, lt: self, rt: self)
    @val = val
    @lt = lt
    @rt = rt
  end

  def add(item)
    item.rt = self
    item.lt = self.lt

    self.lt.rt = item
    self.lt = item
  end

  def to_a
    buf = [self]
    item = self.rt

    while item != self
      buf << item
      item = item.rt
    end

    buf
  end
end

board = 'TXOX'
header = DoublyLinkedList.new(board[0])

board[1..-1].chars.each do |cell|
  new_cell = DoublyLinkedList.new(cell)
  header.add(new_cell)
end

puts header.to_a.map(&:val).join

# # Board:
#     T X
#     X X
#
# # Pieces
#     [T X], [X X]
#
# # Solutiom Matrix
#
#     T X X X Header
#     ------- TX
#     1 1 0 0
#     1 0 1 0
#     ------- XX
#     0 1 0 1
#     0 0 1 1
