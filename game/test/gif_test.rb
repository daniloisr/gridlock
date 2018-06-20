require 'byebug'
require 'minitest/autorun'

require_relative '../lib/gif.rb'

class GifTest < Minitest::Test
  def setup
    @gif = Gif.new(File.join(File.dirname(__FILE__), 'sheet.gif'))
  end

  def test_image_dimensions
    assert_equal [24, 10], [@gif.width, @gif.height]
  end

  def test_image_data
    result = @gif.image_data.each_slice(@gif.width).map(&:join).join("\n")
    assert_equal <<~BIN.chomp, result
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
    BIN
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
