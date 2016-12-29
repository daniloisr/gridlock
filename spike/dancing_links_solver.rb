require 'ostruct'
require 'byebug'

# attributes
# left, right, up, down, column, size, name
Cell = Class.new(OpenStruct)

board = 'txxx'
pieces = ['tx', 'xx']

header = prev = Cell.new

# setup columns
for i in 0..1 do
  for j in 0..1 do
    cell = Cell.new

    prev.right = cell
    cell.left = prev
    prev = cell

    cell.size = 0
    cell.name = board[i * 2 + j]
  end

  prev.right = header
  header.left = prev
end

byebug
1


# T X
# X X
#
# Solutiom matrix for pieces TX and XX
# T X X X Header
# ------- TX
# 1 1 0 0
# 1 0 1 0
# ------- XX
# 0 1 0 1
# 0 0 1 1
