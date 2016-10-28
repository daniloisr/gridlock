# http://ascii-table.com/ansi-escape-sequences.php
# http://unix.stackexchange.com/questions/26576/how-to-delete-line-with-echo
# ┌───┬───┬───┐
# │ ✚ │ ■ │ ● │
# ├───┼───┼───┤
# │ ✚ │ ◼ │ ● │
# └───┴───┴───┘

gd, g = [4, <<~GRID.gsub("\n",'')]
  TXOO
  OTTX
  XXOX
GRID

pieces = [2, :a, 'XO']
placed = [1, :a, 0]

map = <<~MAP.split("\n").map(&:split).to_h
  X ✚
  T ■
  O ●
MAP

# -------------------------
puts ?┌ + (['───']*gd)*?─ + ?┐

g.chars.each_slice(gd).each_with_index do |cells, i|
  cells = cells.map{|i| map[i] }
  puts '│ ' + cells * '   ' + ' │'
  # puts ?┌ + (['───']*gd)*?┬ + ?┐
  puts ?│ + (['   ']*gd)*' ' + ?│ if g.size - i*gd > gd
end

puts ?└ + (['───']*gd)*?─ + ?┘

# ------------------
pieces = [2, :a, 'XO']
placed = [0, :a, 0]
r = g.size / gd + 1

p1, p2, p3 = placed
i,j = p1/gd, p1%gd
print "\e[#{(r - i) * 2 - 1}A\e[4C┌" + "\e[7C┐"
print "\e[B\e[9D│" + "\e[7C│"
print "\e[B\e[9D└"  + "─"*(4*2 -1) + "┘"
print "\e[10B\e[100C"
