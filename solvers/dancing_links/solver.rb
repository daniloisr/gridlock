def link_solutions(board, pieces, cols)
  pieces.each_with_index do |piece, pi|
    matches = find_matches(board, piece)

    matches.each do |match|
      head, = els = Array.new(match.size.succ) { create_el }
      head[:c] = cols[pi]

      # horizontal links
      els.each_cons(2) { |a, b| link(a, b) }

      # vertical links
      link(head[:c], head, :d, :u)
      match.each_with_index do |m, i|
        c  = cols[pieces.size + m]
        el = els[i + 1]
        c[:s] += 1
        el[:c] = c

        link(c, el, :d, :u)
      end
    end
  end
end

def create_el(initial = {})
  hash = Hash.new do |h, k|
    next h[k] = h if %i[l u r d].include?(k)
    next h[k] = 0 if k == :s
  end
  hash.merge(initial)
end

def create_columns(board, pieces)
  els = ([nil] + pieces + board[:cells]).map { |i| create_el(n: i) }
  els.each_cons(2) { |a, b| link(a, b) }
  els.first
end

def create_solve_matrix(board, pieces)
  root = create_columns(board, pieces)
  link_solutions(board, pieces, walk(root, skip: 1))
  root
end

def link(a, b, pr = :l, su = :r)
  b[pr]     = a
  b[su]     = a[su]
  a[su][pr] = b
  a[su]     = b
end

def find_matches(board, piece)
  matches = []
  board[:cells].size.times do |i|
    4.times do |rotation|
      s = []

      piece[:cells].size.times do |j|
        jx, jy = ((j / piece[:width] + (j % piece[:width]) * 1i) * 1i**rotation).rect
        ix, iy = [(i / board[:width]) + jx, (i % board[:width]) + jy]
        i2 = ix * board[:width] + iy
        break if ix < 0 || i2 >  board[:cells].size ||
                 iy < 0 || iy >= board[:width]

        break if board[:cells][i2] != piece[:cells][j]

        s << i2

        if j == piece[:cells].size - 1
          matches << s.sort
          break
        end
      end
    end
  end

  matches.uniq
end

def walk(ref, skip: nil, dir: :r)
  p = skip ? ref[dir] : ref
  stop = ref

  [].tap do |y|
    loop do
      y << p
      p = p[dir]
      break if p == stop
    end
  end
end

def new_grid(str)
  lines = str.delete(' ').split
  { width: lines.first.size, cells: lines.join.chars }
end

def print_matrix(root)
  buf = []
  printed = []
  cols = walk(root, skip: 1)

  buf <<
    cols
    .each_with_index
    .map { |e, i| e[:n].is_a?(String) ? e[:n].upcase : i + 1 }

  cols.each do |col|
    walk(col, dir: :d, skip: 1).each do |row|
      next if printed.include?(row)
      walk(row).each { |el| printed << el }

      el_cols = walk(row).map { |el| el[:c] }
      buf << cols.map { |col2| el_cols.include?(col2) ? 'x' : '.' }
    end
  end

  buf.map { |i| i.join(' ') }.join("\n")
end
