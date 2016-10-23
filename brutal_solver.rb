require 'minitest/autorun'

class Solver
  def self.solve((gd, g), ps)
    i = 0
    i += 1 while g[i] == '_'
    return true if i == g.size
    puts g.chars.each_slice(gd).map(&:join), "\n"
    puts ps

    ps.each_with_index.any? do |p, j|
      new_p = ps.dup
      new_p.delete_at(j)

      if (p[0] == g[i] && p[1] == g[i + 1])  # right
        new_g = g.dup
        new_g[i] = new_g[i + 1] = '_'
        return true if solve([gd, new_g], new_p)
      end

      if (p[0] == g[i] && p[1] == g[i + gd]) # down
        new_g = g.dup
        new_g[i] = new_g[i + gd] = '_'
        return true if solve([gd, new_g], new_p)
      end

      if (p[0] == g[i] && p[1] == g[i -  1]) # left
        new_g = g.dup
        new_g[i] = new_g[i - 1] = '_'
        return true if solve([gd, new_g], new_p)
      end

      if (p[0] == g[i] && p[1] == g[i - gd]) # up
        new_g = g.dup
        new_g[i] = new_g[i - gd] = '_'
        return true if solve([gd, new_g], new_p)
      end
    end

    false
  end
end

class TestSolver < Minitest::Test
  def test_solve_no_rotation
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

  def test_solve_with_rotation
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
end
