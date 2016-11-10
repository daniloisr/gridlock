require 'pp'

class Solver
  # gd = grid dimension
  # g = grid
  # ps = pieces
  # gi = grid index
  def self.solve((gd, g), ps, i = 0, placed = [])
    all_placed = ps.all? {|(_, _, available)| !available }
    return [all_placed, all_placed ? placed : []] if i >= g.size
    return solve([gd, g], ps, i + 1, placed) if g[i] == '_'

    skipped_at = g.slice(/^_*[^_]/).size - 1
    return [false, []] if i - skipped_at > gd + 1

    ps.each_with_index.any? do |(pd, p, available), j|
      next if p[0] != g[i] || !available

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
          ps[j][2] = false

          branch = solve([gd, new_g], ps, i + 1, [*placed, [i, j, ri]])
          if branch[0]
            return branch
          else
            ps[j][2] = true
          end
        end
      end
    end

    solve([gd, g], ps, i + 1, placed)
  end
end
