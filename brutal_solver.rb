require 'minitest/autorun'
require 'byebug'

class Solver
  # gd = grid dimension
  # g = grid
  # ps = pieces
  # gi = grid index
  # pd = piece dimension
  def self.solve((gd, g), ps, i = 0, pd = 2)
    return g =~ /^_*$/ if i >= g.size
    return solve([gd, g], ps, i + 1) if g[i] == '_'

    rotations = [
      [  1, i % gd != gd - 1], # right
      [ gd, i + gd < g.size],  # down
      [ -1, i % gd != 0],      # left
      [-gd, i - gd > 0]        # up
    ]

    ps.each_with_index.any? do |p, j|
      new_ps = ps.dup
      new_ps.delete_at(j)

      rotations.each_with_index.any? do |(r, in_board), ri| # rotation
        next unless in_board

        rotated = pd.times.map {|k| i + k * r }
        if pd.times.all? {|k| p[k] == g[rotated[k]] }
          new_g = g.dup
          rotated.each {|j| new_g[j] = '_' }
          return true if solve([gd, new_g], new_ps, i + 1)
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

  def test_2d_piece
    grid = <<~GRID.gsub("\n",'')
      TOXO
      TOXX
    GRID
    grid = [4, grid]

    pieces = []
    pieces << 'TOT'
    pieces << 'XOX'
    pieces << 'OX'

    assert Solver.solve(grid, pieces)
  end
end
