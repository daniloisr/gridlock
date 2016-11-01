# http://ascii-table.com/ansi-escape-sequences.php
# http://unix.stackexchange.com/questions/26576/how-to-delete-line-with-echo
# ┌───┬───┬───┐
# │ ✚ │ ■ │ ● │
# ├───┼───┼───┤
# │ ✚ │ ◼ │ ● │
# └───┴───┴───┘

require 'minitest/autorun'
require 'byebug'
require 'pp'

# gd, g = [4, <<~GRID.gsub("\n",'')]
#   TXOO
#   OTTX
#   XXOX
# GRID

# pieces = [2, :a, 'XO']
# placed = [1, :a, 0]

# map = <<~MAP.split("\n").map(&:split).to_h
#   X ✚
#   T ■
#   O ●
# MAP

# -------------------------
# puts ?┌ + (['───']*gd)*?─ + ?┐

# g.chars.each_slice(gd).each_with_index do |cells, i|
#   cells = cells.map{|i| map[i] }
#   puts '│ ' + cells * '   ' + ' │'
#   # puts ?┌ + (['───']*gd)*?┬ + ?┐
#   puts ?│ + (['   ']*gd)*' ' + ?│ if g.size - i*gd > gd
# end

# puts ?└ + (['───']*gd)*?─ + ?┘

# # ------------------
# pieces = [2, :a, 'XO']
# placed = [0, :a, 0]
# r = g.size / gd + 1

# p1, p2, p3 = placed
# i,j = p1/gd, p1%gd
# print "\e[#{(r - i) * 2 - 1}A\e[4C┌" + "\e[7C┐"
# print "\e[B\e[9D│" + "\e[7C│"
# print "\e[B\e[9D└"  + "─"*(4*2 -1) + "┘"
# print "\e[10B\e[100C"

class Grid
  Cell = Struct.new(:symbol, :filled_with)

  attr_reader :width, :height

  def initialize(width, cells)
    @width = width
    @cells = cells
    @height = (cells.size / width.to_f).ceil
  end

  def solve(pieces)
    @pieces = pieces
  end

  def [](y, x)
    if y.between?(0, @height - 1) && x.between?(0, @width - 1)
      Cell.new(@cells[y * width + x])
    else
      Cell.new
    end
  end
end

Piece = Board = Grid

class Printer
  def initialize(board)
    @board = board
  end

  def print
    h, w = @board.height, @board.width
    out = []

    h.times do |y|
      out << print_separator(y, w).join
      out << print_cells(y, w).join
    end

    out << print_separator(h, w).join
  end

  def print_cells(y, w)
    b = @board

    out = w.times.flat_map do |x|
      out = []

      cells =
        [b[y, x-1], b[y, x],
         b[y, x-1], b[y, x]].
        map(&:symbol)

      val = (1..3).
        map {|i| cells.uniq.index(cells[i]) }.
        join

      out << separator_map[val]

      out << ' ' + symbol_map[b[y, x].symbol] + ' '
    end

    cells =
      [b[y, w-1], b[y, w],
       b[y, w-1], b[y, w]].
      map(&:symbol)

    val = (1..3).
      map {|i| cells.uniq.index(cells[i]) }.
      join

    out << separator_map[val]
  end

  def print_separator(y, w)
    b = @board

    out = w.times.flat_map do |x|
      out = []

      cells =
        [b[y-1, x-1], b[y-1, x],
         b[y  , x-1], b[y  , x]].
        map(&:symbol)

      val = (1..3).
        map {|i| cells.uniq.index(cells[i]) }.
        join

      out << separator_map[val]

      cells =
        [b[y-1, x], b[y-1, x],
         b[y  , x], b[y  , x]].
        map(&:symbol)

      val = (1..3).
        map {|i| cells.uniq.index(cells[i]) }.
        join

      out << separator_map[val]*3
    end

    cells =
      [b[y-1, w-1], b[y-1, w],
       b[y  , w-1], b[y  , w]].
      map(&:symbol)

    val = (1..3).
      map {|i| cells.uniq.index(cells[i]) }.
      join

    out << separator_map[val]
  end

  def separator_map
    {
      '000' => ' ',
      '001' => "\u250c",
      '010' => "\u2510",
      '011' => "\u2500",
      '012' => "\u252c",
      '100' => "\u2514",
      '101' => "\u2502",
      '102' => "\u251c",
      '110' => "\u253c",
      '111' => "\u2518",
      '112' => "\u253c",
      '120' => "\u253c",
      '121' => "\u2524",
      '122' => "\u2534",
      '123' => "\u253c",
    }
  end

  def symbol_map
    {
      nil => ' ',
      '_' => ' ',
      'X' => "\u271a",
      'T' => "\u25a0",
      'O' => "\u25cf",
    }
  end
end

class PrinterTest < Minitest::Test
  def test_print_single_cell
    board = Board.new(1, 'T')

    assert Printer.new(board).print.join("\n") == <<~OUT.chomp
      ┌───┐
      │ ■ │
      └───┘
    OUT
  end
end
