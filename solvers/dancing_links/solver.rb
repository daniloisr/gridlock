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
  # meanings
  # l u r d => left up right down
  # s => size
  # c => column ref
  # n => name
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
  return [] if skip && p == ref

  [].tap do |y|
    loop do
      y << p
      p = p[dir]
      break if p == ref
    end
  end
end

def new_grid(str)
  lines = str.delete(' ').split
  { width: lines.first.size, cells: lines.join.chars }
end

def clone(root)
  nroot = nil
  queue = [root]
  memo = { root.object_id => create_el(clone_of: root) }

  until queue.empty?
    # @todo chose a single name "node" or "el"
    node = queue.shift
    nnode = memo[node.object_id]
    nroot ||= nnode

    %i[l u r d c].each do |k|
      n = node[k]
      oid = n.object_id

      next unless n

      unless memo[oid]
        memo[oid] = create_el(clone_of: n)
        queue.push(n)
      end

      nnode[k] = memo[oid]
    end

    %i[s n].each { |k| nnode[k] = node[k] }
  end

  nroot
end

def print_matrix(root, ref_root = nil)
  buf = []
  printed = []
  cols = walk(root, skip: 1)
  cols_ref = ref_root ? walk(ref_root, skip: 1).map { |i| i[:clone_of] } : cols

  buf.push(
    cols_ref
    .each_with_index
    .map do |e, i|
      if    !cols.include?(e)   then nil
      elsif e[:n].is_a?(String) then e[:n].upcase
      else i + 1
      end
    end
    .compact
  )

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

def debug_node(node)
  return 'nil' unless node
  %i[l u r d]
    .map { |k| [k, node[k]] }
    .unshift([:self, node])
    .select { |(_, b)| b }
    .map { |(a, b)| [a, b.object_id.to_s(16)[-4..-1]].join(':') }
    .push(node[:n] ? "n:#{node[:n]}" : nil)
    .join(' ')
end

def search(root, out = nil)
  out ||= {
    memo: {},
    result: []
  }

  return out if root == root[:r]

  # @todo chose the best column to run
  col = walk(root, skip: 1).first

  cover(col)
  # @todo try to remove the ".each" after "walk()" method
  # @todo ".take(1)" is the first piece fit, we need to iterate on all
  walk(col, dir: :d, skip: 1).take(1).each_with_index do |row, index|
    out[:result] << [row[:c], index]
    walk(row).each do |el|
      next if out[:memo][el[:c].object_id]
      out[:memo][el[:c].object_id] = true
      cover(el[:c])
    end

    return out if search(root, out)

    # @todo uncover...
    out[:result].pop
    walk(row).each do |el|
      out[:memo].delete(el[:c].object_id)
      uncover(el[:c])
    end
  end

  uncover(col)

  out
end

def cover(col)
  col[:l][:r] = col[:r]
  col[:r][:l] = col[:l]

  walk(col, dir: :d, skip: 1).each do |row|
    walk(row, skip: 1).each do |el|
      # @todo reduce el[:s] when selecting columns by size
      el[:u][:d] = el[:d]
      el[:d][:u] = el[:u]
    end
  end
end

def uncover(col)
  # @todo remove "skip: 1", it is used all the times on "search()"
  walk(col, dir: :d, skip: 1).each do |row|
    walk(row, skip: 1).each do |el|
      # @todo increase el[:s] when selecting columns by size
      el[:u][:d] = el
      el[:d][:u] = el
    end
  end

  col[:l][:r] = col
  col[:r][:l] = col
end
