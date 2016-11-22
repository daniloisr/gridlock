require 'grid'
require 'solver'
require 'printer'

grid = <<~GRID.gsub("\n",'')
  TXOO
  OTTX
  XXOX
  XTOT
  XTXX
  OTOO
  OOTT
GRID
board = Board.new(4, grid)

a = 'XO'
b = 'XT'
c = 'TO'
d = 'XX'
f = 'OO'
g = 'TOT'
i = 'OTX'
j = 'XXT'
k = 'OOT'

pieces = [a,a,b,b,c,c,d,f,g,i,j,k].map {|i| Piece.new(2, i)}
puts "solving game 'AABBCCDFGIJK' ..."

# Warning: GOHORSE code bellow
solution = Solver.solve(board, pieces)
board = solution[:board]
pieces = solution[:pieces]
blines = Printer.new(board).print
height = blines.size
width = 19
pieces = pieces.shuffle

pieces.size.times do |piece_num|
  new_board = board.dup
  new_board.cells.each do |_,c|
    next if c.filled_with.nil?
    unless pieces.take(piece_num + 1).include?(c.filled_with.root)
      c.filled_with = nil
    end
  end

  blines = Printer.new(new_board).print
  blines.each do |line|
    puts line
  end

  print "\e[#{height}A\e[#{width + 1}C"

  plines = 0
  pieces.take(piece_num + 1).reverse.each_with_index do |piece, index|
    piece = piece.dup
    piece[0,0].filled_with = piece
    piece[0,1].filled_with = piece
    piece[1,0].filled_with = piece unless piece[1,0].symbol.nil?
    lines = Printer.new(piece).print
    lines.each do |line|
      next if plines >= height
      print "\e[32m#{line}\e[0m" if index == 0
      print "\e[90m#{line}\e[0m" if index > 0

      print "\e[1B\e[#{5 * 2 - 1}D"
      plines += 1
    end
  end

  sleep 2
  print "\e[#{height}B\e[#{height}A\e[#{width + 1}D"
end

print "\e[#{height}B\n"
