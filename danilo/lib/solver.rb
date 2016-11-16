require 'grid'

class Solver
  # gd = grid dimension
  # g = grid
  # ps = pieces
  # gi = grid index
  def self.solve(board, ps, i = 0, placed = [])
    g = board; gd = board.width

    all_placed = ps.all? {|p| !piece.available? }
    return [all_placed, all_placed ? placed : []] if i >= g.symbols.size
    return solve(board, ps, i + 1, placed) if g[i].filled

    return [false, []] if i - board.skipped_at > gd + 1

    ps.each_with_index.any? do |(piece), j|
      pd, p = [piece.width, piece.symbols]
      next if p[0] != g[i].symbol || !piece.available?

      4.times.any? do |ri| # rotation
        rotated = []
        fit = p.size.times.all? do |k|
          next true if p[k] == '_'
          a,b = ((k%pd + k/pd*1i) * 1i**ri).rect
          rotated << gi = i + a + b*gd

          p[k] == g[gi].symbol if (i%gd + a).between?(0, gd-1) && (i/gd + b).between?(0, g.symbols.size/gd)
        end

        if fit
          new_board = board.dup
          rotated.each {|j| new_board[j].filled = true }
          ps[j][2] = false

          branch = solve(new_board, ps, i + 1, [*placed, [i, j, ri]])
          if branch[0]
            return branch
          else
            ps[j][2] = true
          end
        end
      end
    end

    solve(board, ps, i + 1, placed)
  end
end
