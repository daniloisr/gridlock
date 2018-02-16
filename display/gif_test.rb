require 'byebug'
require 'minitest/autorun'

class Gif
  attr_reader :width, :height, :image_data

  def initialize(fname)
    read_file(fname)
  end

  private

  # www.matthewflickinger.com/lab/whatsinagif/bits_and_bytes.asp
  # http://devdocs.io/ruby~2.5/string#method-i-unpack
  def read_file(fname)
    File.open('./sheet.gif') do |f|
      # skip header
      _header = f.read(6)

      logical_screen_descriptor = f.read(7)
      @width, @height, packed_field = logical_screen_descriptor.unpack('SSC')

      # skip color table
      # I don't think I'll need the collor table, I'll map the colors internaly based on each entity state
      color_table_size = (packed_field & 0b111) + 1
      _color_table = f.read(3 * 2**color_table_size)
      # color_table_hex = color_table.unpack('H2' * 3 * 2**color_table_size)
      # puts color_table_hex.join(', ')

      # skip image descriptor
      _image_descriptor = f.read(10)

      @image_data =
        [].tap do |buf|
          # discart first byte: LZW minimum code size
          # byte = f.getbyte
          while (byte = f.getbyte) != 0
            buf << byte
          end
        end
    end
  end
end

class LZW
  # http://www.matthewflickinger.com/lab/whatsinagif/lzw_image_data.asp
  def self.decompress(data)
    tsize = data.shift
    bytes_in_block = data.shift
    current_code_size = tsize + 1
    table = Array.new(2**tsize) { |i| [i, [i]] }.to_h
    end_of_information = 2**tsize + 1
    table_new_index = end_of_information + 1

    code = bit_from_stream(data, current_code_size, current_code_size)
    last_code = code
    index_stream = [table[code]]
    bit_index = current_code_size*2
    code_stream = [code]

    code = bit_from_stream(data, bit_index, current_code_size)
    while code && code != end_of_information && bit_index < data.size*8
      code_stream << code
      if table.has_key?(code)
        index_stream << table[code]
        k = table[code].first
        table[table_new_index] = table[last_code] + [k]
        table_new_index += 1
      else
        k = table[last_code].first
        table[table_new_index] = table[last_code] + [k]
        index_stream << table[table_new_index]
        table_new_index += 1
      end

      last_code = code
      bit_index += current_code_size
      if table_new_index == 2**current_code_size
        current_code_size += 1
      end

      code = bit_from_stream(data, bit_index, current_code_size)
    end

    index_stream.flatten
  end

  # data is a array of bytes
  # bit_index is t
  def self.bit_from_stream(data, bit_index, size)
    # using bitwise operations
    # i, mod = bit_index.divmod(8)
    # offset = size + mod
    # bit1 = (data[i] >> 8 - [offset, 8].min) & ((1 << size) - 1)
    # return bit1 if offset <= 8

    # next_size = offset % 8
    # (bit1 << next_size) + bit_from_stream(data, i + 8, next_size)

    # using unpack/pack
    i, offset = bit_index.divmod(8)
    data[i, 2].reverse.pack('C*').unpack1('B16')[-offset - size, size]&.to_i(2)
  end
end

class GifTest < Minitest::Test
  def setup
    @gif = Gif.new('./sheet.gif')
  end

  def test_image_dimensions
    assert_equal [24, 10], [@gif.width, @gif.height]
  end

  def test_image_data
    assert_equal <<~bin.chomp, LZW.decompress(@gif.image_data).each_slice(@gif.width).map(&:join).join("\n")
      100001111100111100000011
      001100110000001100000011
      100001111100111100000011
      111111111111111111111111
      000000111111111111111111
      011110111111111111111111
      011110111111111111111111
      011110111111111111111111
      011110111111111111111111
      000000111111111111111111
    bin
  end
end

class LZWTest < Minitest::Test
  def test_decompress
    assert_equal [1, 1, 1, 1, 1, 2, 2, 2, 2, 2], LZW.decompress([0x02, 0x03, 0x8C, 0x2D, 0x99])
  end

  def test_bit_from_stream_simple_byte
    bin = [0b10001000]
    assert_equal 0, LZW.bit_from_stream(bin, 0, 3)
    assert_equal 1, LZW.bit_from_stream(bin, 3, 3)
    assert_equal 2, LZW.bit_from_stream(bin, 6, 2)
  end

  def test_bit_from_stream_multiple_byte
    assert_equal 3, LZW.bit_from_stream([0x80, 0x03], 7, 2)
    assert_equal 7, LZW.bit_from_stream([0x80, 0x03], 7, 3)
  end
end
