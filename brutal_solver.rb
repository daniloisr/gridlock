require 'minitest/autorun'
require 'byebug'

class Solver
  def self.solve((gd, g), ps, i = 0, pd = 2)
    return solve([gd, g], ps, i + 1) if g[i] == '_'
    return g =~ /^_*$/ if i >= g.size

    ps.each_with_index.any? do |p, j|
      new_p = ps.dup
      new_p.delete_at(j)

      checks =
        [ i % gd != gd - 1, # right
          i + gd < g.size,  # down
          i % gd != 0,      # left
          i - gd > 0]       # up
      [1, gd, -1, -gd].each_with_index.any? do |r, ri| # rotation
        next unless checks[ri]

        rotated = pd.times.map {|k| i + k * r }
        if pd.times.all? {|k| p[k] == g[rotated[k]] }
          new_g = g.dup
          rotated.each {|j| new_g[j] = '_' }
          return true if solve([gd, new_g], new_p, i + 1)
        end
      end
    end

    return solve([gd, g], ps, i + 1)
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
    pieces << 'TO'
    pieces << 'TO'
    pieces << 'XX'
    pieces << 'XO'

    assert Solver.solve(grid, pieces)
  end

  def test_simple_rotation
    grid = <<~GRID.gsub("\n",'')
      TOX
      TOX
    GRID
    grid = [3, grid]

    pieces = []
    pieces << 'OX'
    pieces << 'TT'
    pieces << 'OX'

    assert Solver.solve(grid, pieces)
  end

  def test_left_insert
    grid = [2, 'TO']
    pieces = ['OT']

    assert Solver.solve(grid, pieces)
  end

  def test_board_side_limits
    grid = <<~GRID.gsub("\n",'')
      TOX
      TOX
    GRID
    grid = [3, grid]

    pieces = []
    pieces << 'OX'
    pieces << 'TO'
    pieces << 'TX'

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
    pieces << 'TX'
    pieces << 'OX'
    pieces << 'OX'

    refute Solver.solve(grid, pieces)

    pieces = []
    pieces << 'XT'
    pieces << 'OX'
    pieces << 'XO'

    refute Solver.solve(grid, pieces)
  end
end
