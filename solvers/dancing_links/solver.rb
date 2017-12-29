module DancingLinks
  def link_solutions(board, pieces, cols)
    pieces.each_with_index do |piece, pi|
      matches = find_matches(board, piece)

      matches.each do |(match, rotation)|
        head, = els = Array.new(match.size.succ) { Node.new rotation: rotation }
        head.column = cols[pi]
        head.column.size += 1

        # horizontal links
        els.each_cons(2) { |a, b| link(a, b) }

        # vertical links
        link(head.column, head, :d, :u)
        match.each_with_index do |m, i|
          c  = cols[pieces.size + m]
          el = els[i + 1]
          c.size += 1
          el.column = c

          link(c, el, :d, :u)
        end
      end
    end
  end

  # Columns are composed of three components:
  # 1. A first nil column to be used as the main pointer of the table
  # 2. All pieces
  # 3. All board cells
  def create_columns(board, pieces)
    cols = []
    cols << Node.new(root: true)

    cols +=
      pieces
      .each_with_index
      .map { |piece, i| Node.new name: (i + 1).to_s, piece: piece }

    cols +=
      board[:cells]
      .each_with_index
      .map { |cell, i| Node.new name: cell, index: i }

    cols.each_cons(2) { |a, b| link(a, b) }

    # return the root node (pointer of the table)
    cols.first
  end

  def create_solve_matrix(board, pieces)
    create_columns(board, pieces).tap do |root|
      link_solutions(board, pieces, walk(root, skip: 1))
    end
  end

  def link(a, b, prev = :l, succ = :r)
    b[prev] = a
    b[succ] = a[succ]
    a[succ][prev] = b
    a[succ] = b
  end

  def find_matches(board, piece)
    matches = []
    board[:cells].size.times do |i|
      4.times do |rotation|
        s = []

        piece[:cells].size.times do |j|
          jx, jy =
            ((j / piece[:width] + (j % piece[:width]) * 1i) * 1i**rotation).rect
          ix = (i / board[:width]) + jx
          iy = (i % board[:width]) + jy
          i2 = ix * board[:width] + iy
          break if ix.negative? || i2 >  board[:cells].size ||
                   iy.negative? || iy >= board[:width]

          break if board[:cells][i2] != piece[:cells][j]

          s << i2

          if j == piece[:cells].size - 1
            # @todo improve this "unless" condition
            matches << [s.sort, rotation] unless matches.any? { |pos, _| pos == s.sort }
            break
          end
        end
      end
    end

    matches
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

  def grid(str)
    lines = str.delete(' ').split
    { width: lines.first.size, cells: lines.join.chars }
  end
  alias piece grid

  def print_matrix(root)
    buf = []
    cols = walk(root, skip: 1)

    buf.push(cols.map { |e| e.name.upcase })

    cols.select(&:piece).each do |col|
      walk(col, dir: :d, skip: 1).each do |row|
        el_cols = walk(row).map(&:column)
        # @todo keep track of the column number on matrix, so we can this "include?" check
        #       eg:
        #         el_cols.first.column.number
        buf << cols.map { |col2| el_cols.include?(col2) ? 'x' : '.' }
      end
    end

    buf.map { |i| i.join(' ') }.join("\n")
  end

  def search(root, result = [])
    # return the result when there is no more piece to cover
    return result if root == root.r

    col = walk(root, skip: 1).min_by(&:size)

    # walk through all rows in the column, trying to cover them
    walk(col, dir: :d, skip: 1).each do |row|
      result.push row
      cover(row)

      # Go to the next search step
      return result if search(root, result)

      # The search through "row" failed, uncover it
      result.pop
      uncover(row)
    end

    # The search failed
    false
  end

  # When covering a column we need to remove the reference of its left
  # an right columns and also remove all rows for the piece
  def cover(row)
    walk(row).each do |node|
      col = node.column
      col.l.r = col.r
      col.r.l = col.l

      walk(col, dir: :d, skip: 1).each do |row2|
        row2.column.size -= 1
        walk(row2, skip: 1).each do |el|
          el.column.size -= 1
          el.u.d = el.d
          el.d.u = el.u
        end
      end
    end
  end

  def uncover(row)
    walk(row).each do |node|
      col = node.column
      walk(col, dir: :d, skip: 1).each do |row2|
        # @todo these conditions may not be needed
        row2.column.size += 1 if col.l.r != col || # increment board columns when it wasn't uncovered
                                 col.piece         # increment piece columns always
        walk(row2).each do |el|
          el.column.size += 1 if el.u.d != el # increment board column if they aren't uncovered
          el.u.d = el
          el.d.u = el
        end

        col.l.r = col
        col.r.l = col
      end
    end
  end

  class Node
    attr_accessor :left, :up, :right, :down
    attr_accessor :size, :column
    attr_reader :name, :rotation, :root, :piece, :index

    alias l left
    alias u up
    alias r right
    alias d down

    alias l= left=
    alias u= up=
    alias r= right=
    alias d= down=

    def self.directions
      %i[l u r d]
    end

    def initialize(**args)
      @left = args[:l] || self
      @up = args[:u] || self
      @right = args[:r] || self
      @down = args[:d] || self
      @name = args[:name]
      @piece = args[:piece]
      @rotation = args[:rotation]
      @root = args[:root]
      @index = args[:index]
      @size = 0
      @column = nil
    end

    def [](direction)
      public_send(direction) if self.class.directions.include?(direction)
    end

    def []=(direction, value)
      return unless self.class.directions.include?(direction)
      public_send("#{direction}=", value)
    end

    def inspect
      %i[l u r d]
        .map { |k| [k, send(k)] }
        .unshift([:self, self])
        .select { |(_, b)| b }
        .map { |(a, b)| [a, b.id].join(':') }
        .push(name ? "n:#{name}" : nil)
        .push(root ? 'root' : nil)
        .compact
        .join(' ')
    end

    def id
      object_id.to_s(16)[-4..-1]
    end
  end
end
