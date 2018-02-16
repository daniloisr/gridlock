# use block elements to draw the entities
#  * https://en.wikipedia.org/wiki/Block_Elements
#  * reference https://github.com/eliukblau/pixterm
#
# color escape sequence
#  * https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
#
# indexed image for sprites:
#  * https://en.wikipedia.org/wiki/Indexed_color#Image_file_formats_supporting_indexed_color
#
# gif format:
#  * http://www.matthewflickinger.com/lab/whatsinagif/bits_and_bytes.asp
#  * http://commandlinefanatic.com/cgi-bin/showarticle.cgi?article=art011
#
# lzw compression
#  * http://www.matthewflickinger.com/lab/whatsinagif/lzw_image_data.asp
#  * https://rosettacode.org/wiki/LZW_compression#Ruby
#
# ruby png lib for code reference:
#  * https://github.com/wvanbergen/chunky_png/blob/master/lib/chunky_png/chunk.rb
require 'minitest/autorun'
require 'byebug'

class Display
  def self.sample_data
    [
      [0b011110,
       0b110011,
       0b011110,
       0b000000],
      [0b001100,
       0b111111,
       0b001100,
       0b000000],
      [0b011111,
       0b011111,
       0b011111,
       0b000000],
    ]
  end


  def self.print(idx = 0)
    width = 2
    height = 3

    width.times.map do |i|
      i = i * 2
      row_a, row_b = sample_data[idx][i..(i+1)]
      height.times.map do |j|
        mask = 0b11
        offset = (3 - j - 1)*2

        final = row_a >> offset & mask
        final = final << 2
        final + (row_b >> offset & mask)
      end
    end
  end

  # https://en.wikipedia.org/wiki/Block_Elements#Character_table
  def self.character_map
    {
      0b0000 => ' ',
      0b1111 => "\u2588", # U+2588 	█ 	Full block
      0b1000 => "\u2598", # U+2598 	▘ 	Quadrant upper left
      0b0100 => "\u259D", # U+259D 	▝ 	Quadrant upper right
      0b0010 => "\u2596", # U+2596 	▖ 	Quadrant lower left
      0b0001 => "\u2597", # U+2597 	▗ 	Quadrant lower right
      0b1100 => "\u2580", # U+2580 	▀ 	Upper half block
      0b0101 => "\u2590", # U+2590 	▐ 	Right half block
      0b0011 => "\u2584", # U+2584 	▄ 	Lower half block
      0b1010 => "\u258C", # U+258C 	▌ 	Left half block
      0b1110 => "\u259B", # U+259B 	▛ 	Quadrant upper left and upper right and lower left
      0b1101 => "\u259C", # U+259C 	▜ 	Quadrant upper left and upper right and lower right
      0b1011 => "\u2599", # U+2599 	▙ 	Quadrant upper left and lower left and lower right
      0b0111 => "\u259F", # U+259F 	▟ 	Quadrant upper right and lower left and lower right
      0b1001 => "\u259A", # U+259A 	▚ 	Quadrant upper left and lower right
      0b0110 => "\u259E", # U+259E 	▞ 	Quadrant upper right and lower left
    }
  end

  def self.entity_to_character(idx = 0)
    Display.print(idx).map do |row|
      row.map { |column| character_map[column] }
    end
  end
end

class DisplayTest < Minitest::Test
  def test_print
    result = Display.print.map { |i| i.map { |j| format('%.4b', j) } }
    assert false
    assert_equal [['0111', '1100', '1011'], ['0100', '1100', '1000']], result
  end

  def test_entity_to_character
    results = 3.times.map{|i| Display.entity_to_character(i) }
    5.times do
      x = results.shuffle
      2.times do |row|
        3.times do |i|
          print x[i][row].join
          print '  '
        end
        puts
      end
      puts
    end
  end
end

# vim :let $MT_NO_PLUGINS = 1
