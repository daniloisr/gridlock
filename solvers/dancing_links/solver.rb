require 'byebug'
require 'ostruct'
require 'minitest'

def main
  # # Solution Matrix
  #
  #    O X X X HEADER
  #    ------- XO piece
  #    x x . .
  #    x . x .
  #    ------- XX piece
  #    . x . x
  #    . . x x
  board = new_grid(<<~HEAD)
    o x
    x x
  HEAD

  # header = setup_header(board)
  # puts each_row(header).map { |p| p[:v] }.join(' ').upcase + ' HEADER'

  piece_xo = new_grid('o x')
  # piece_xx = new_grid('x x')

  puts
end

def setup_header(board)
  head, *tail = board[:cells]
  header = p = { v: head }
  p[:r] = p[:l] = p
  tmp = {}

  tail.each do |cell|
    tmp[:v]   = cell
    tmp[:l]   = p
    tmp[:r]   = p[:r]
    p[:r][:l] = tmp
    p[:r]     = tmp

    p = tmp
    tmp = {}
  end

  header
end

def rotate(x, y, rotation)
  ((x + y * 1i) * 1i**rotation).rect
end

def find_matches(board, piece)
  matches = []
  board[:cells].size.times do |i|
    piece[:cells].size.times do |j|
      4.times do |rotation|
        p = 0
        s = []

        loop do
          jrx, jry = rotate(j / piece[:width], j % piece[:width], rotation)

          break if board[:cells][ir] != piece[:cells][jr]
          s << ir
          p += 1

          if p == piece[:cells].size
            matches << s.sort
            break
          end
        end
      end
    end
  end

  matches.uniq
end

def each_row(ref)
  p = ref

  Enumerator.new do |y|
    loop do
      y << p
      p = p[:r]
      break if p == ref
    end
  end
end

def new_grid(str)
  lines = str.delete(' ').split
  { width: lines.first.size, cells: lines.join.chars }
end

class SolverTest < Minitest::Test
  def board
    new_grid(<<~HEAD)
      o x
      x x
    HEAD
  end

  def test_setup_header
    header = setup_header(board)
    vals = each_row(header).map { |cell| cell[:v] }
    assert_equal 'oxxx', vals.join
  end

  def test_piece_matches
    piece = new_grid('x o')
    matches = find_matches(board, piece)
    assert_equal [[0, 1], [0, 2]], matches
  end
end

Minitest.autorun
