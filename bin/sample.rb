require 'grid'
require 'solver/naive'
require 'printer'
require 'byebug'

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
solution = Marshal.load(File.read('solution.marshal'))
# solution = Solver.solve(board, pieces)
# File.open('solution.marshal', 'w') { |f| f.puts Marshal.dump(solution) }
board = solution[:board]
pieces = solution[:pieces]
blines = Printer.new(board).print
height = blines.size
width = 19
pieces = pieces.shuffle

pieces.size.times do |piece_num|
  new_board = board.clone
  new_board.cells.each do |_,c|
    next unless c.piece_id

    c.piece_id = nil unless pieces.take(piece_num + 1).map(&:id).include?(c.piece_id)
  end

  blines = Printer.new(new_board, color: true).print
  blines.each do |line|
    puts line
  end

  print "\e[#{height}A\e[#{width + 1}C"

  plines = 0
  pieces.take(piece_num + 1).reverse.each_with_index do |piece, index|
    piece = piece.clone
    piece.cell(0,0).piece_id = piece.id
    piece.cell(0,1).piece_id = piece.id
    piece.cell(1,0).piece_id = piece.id unless piece.cell(1,0).symbol.nil?

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
