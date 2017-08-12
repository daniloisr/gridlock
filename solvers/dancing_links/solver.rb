def create_solutions(game)
  board, hrefs, pieces = %i[board hrefs pieces].map { |k| game[k] }

  pieces.map do |piece|
    matches = find_matches(board, piece)

    ss = matches.each_with_object([]) do |match, solutions|
      refs = match.map { create_ref }

      # horizontal links
      refs.each_cons(2) do |a, b|
        b[:l]     = a
        b[:r]     = a[:r]
        a[:r][:l] = b
        a[:r]     = b
      end

      # vertical links
      match.each_with_index do |m, i|
        a = hrefs[m]
        b = refs[i]
        a[:s] += 1
        b[:c]  = a

        b[:u]     = a
        b[:d]     = a[:d]
        a[:d][:u] = b
        a[:d]     = b
      end

      solutions << refs.first
    end

    [piece, ss]
  end
end

def create_ref(initial = {})
  hash = Hash.new do |h, k|
    next h[k] = h if %i[l u r d].include?(k)
    next h[k] = 0 if k == :s
  end
  hash.merge(initial)
end

def setup_header(board)
  head, *tail = board[:cells]
  header = p = create_ref(n: head)
  p[:r] = p[:l] = p
  tmp = create_ref

  tail.each do |cell|
    tmp[:n]   = cell
    tmp[:l]   = p
    tmp[:r]   = p[:r]
    p[:r][:l] = tmp
    p[:r]     = tmp

    p = tmp
    tmp = create_ref
  end

  header
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

def row_cells(ref)
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
