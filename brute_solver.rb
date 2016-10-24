require 'minitest/autorun'
require 'byebug'

class Solver
  @t = Time.new
  # gd = grid dimension
  # g = grid
  # ps = pieces
  # gi = grid index
  def self.solve((gd, g), ps, i = 0, skipped_at = 0)
    return if i - skipped_at > 2 * gd
    return g =~ /^_*$/ if i >= g.size
    return solve([gd, g], ps, i + 1, skipped_at == i ? i + 1 : skipped_at) if g[i] == '_'
    puts "grid: #{g}" if (t = Time.new) - @t > 0.3 && @t = t

    ps.
      select {|(pd, p)| p[0] == g[i] }.
      each_with_index.any? do |(pd, p), j|
        new_ps = ps.dup
        new_ps.delete_at(j)

        4.times.any? do |ri| # rotation
          rotated = []
          fit = p.size.times.all? do |k|
            next true if p[k] == '_'
            a,b = ((k%pd + k/pd*1i) * 1i**ri).rect
            rotated << gi = i + a + b*gd

            p[k] == g[gi] if (i%gd + a).between?(0, gd-1) && (i/gd + b).between?(0, g.size/gd)
          end

          if fit
            new_g = g.dup
            rotated.each {|j| new_g[j] = '_' }
            return true if solve([gd, new_g], new_ps, i + 1, skipped_at == i ? i + 1 : skipped_at)
          end
        end
      end

    solve([gd, g], ps, i + 1, skipped_at)
  end
end

class TestSolver < Minitest::Test
  def test_simple
    grid = <<~GRID.gsub("\n",'')
      TOXO
      TOXX
    GRID
    grid = [4, grid]

    pieces = []
    pieces << [2, 'TO']
    pieces << [2, 'TO']
    pieces << [2, 'XX']
    pieces << [2, 'XO']

    assert Solver.solve(grid, pieces)
  end

  def test_simple_rotation
    grid = <<~GRID.gsub("\n",'')
      TOX
      TOX
    GRID
    grid = [3, grid]

    pieces = []
    pieces << [2, 'OX']
    pieces << [2, 'TT']
    pieces << [2, 'OX']

    assert Solver.solve(grid, pieces)
  end

  def test_left_insert
    grid = [2, 'TO']
    pieces = [[2, 'OT']]

    assert Solver.solve(grid, pieces)
  end

  def test_board_side_limits
    grid = <<~GRID.gsub("\n",'')
      TOX
      TOX
    GRID
    grid = [3, grid]

    pieces = []
    pieces << [2, 'OX']
    pieces << [2, 'TO']
    pieces << [2, 'TX']

    refute Solver.solve(grid, pieces)
  end

  def test_board_up_down_limits
    grid = <<~GRID.gsub("\n",'')
      TO
      OX
      XX
    GRID
    grid = [2, grid]

    pieces = []
    pieces << [2, 'TX']
    pieces << [2, 'OX']
    pieces << [2, 'OX']

    refute Solver.solve(grid, pieces)

    pieces = []
    pieces << [2, 'XT']
    pieces << [2, 'OX']
    pieces << [2, 'XO']

    refute Solver.solve(grid, pieces)
  end

  def test_2d_piece
    grid = <<~GRID.gsub("\n",'')
      TO
      T_
    GRID
    grid = [2, grid]

    pieces = []
    pieces << [2, 'TOT']

    assert Solver.solve(grid, pieces)
  end

  def test_2d_pieces
    grid = <<~GRID.gsub("\n",'')
      TOXO
      TOXX
    GRID
    grid = [4, grid]

    pieces = []
    pieces << [2, 'TOT']
    pieces << [2, 'OXX']
    pieces << [2,  'OX']

    assert Solver.solve(grid, pieces)
  end

  def test_full_board
    grid = <<~GRID.gsub("\n",'')
      TXOO
      OTTX
      XXOX
      XTOT
      XTXX
      OTOO
      OOTT
    GRID
    grid = [4, grid]

    a = 'XO'
    b = 'XT'
    c = 'TO'
    d = 'XX'
    f = 'OO'
    g = 'TOT'
    i = 'OTX'
    j = 'XXT'
    k = 'OOT'

    pieces = [a,a,b,b,c,c,d,f,g,i,j,k].map {|i| [2, i]}

    assert Solver.solve(grid, pieces)
  end
end
