require 'byebug'
require 'rotator'
require 'ostruct'

# attributes
# :left, :right, :up, :down, :column, :size, :name, :piece
MatrixCell = Class.new(OpenStruct)
Piece = Class.new(OpenStruct)
Body = Class.new(OpenStruct) do
  def fit_positions
    [[1]]
  end
end

board = Body.new d: 2, body: 'txxx'
pieces = [[2, 'tx'], [2, 'xx']]

header = prev = MatrixCell.new
headers = []

# setup columns
for i in 0..1 do
  for j in 0..1 do
    cell = MatrixCell.new
    headers << cell

    prev.right = cell
    cell.left = prev
    prev = cell

    cell.up = cell.down = cell

    cell.size = 0
    cell.name = board.body[i * 2 + j]
  end

  prev.right = header
  header.left = prev
end

pieces = pieces.map { |p| Piece.new el: p, cells: [] }
pieces.each do |piece|
  rotator = Rotator.new(piece.p)

  rotator.rotations.each do |rotation|
    positions = board.fit_positions(piece)
    prev = nil

    positions.each do |position|
      cell = MatrixCell.new piece: piece

      if prev
        cell.left = prev
        cell.rigth = prev.right
        prev.right.left = cell
        prev.right = cell
      end

      header = headers[position]
      cell.down = header
      cell.up = header.up
      header.up = cell
      header.up.down = cell

      piece.cells << cell
      prev = cell
    end
  end
end

byebug;1

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
