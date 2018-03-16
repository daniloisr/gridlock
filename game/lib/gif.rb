class Gif
  attr_reader :width, :height, :image_data

  def initialize(fname)
    read_file(fname)
  end

  private

  # www.matthewflickinger.com/lab/whatsinagif/bits_and_bytes.asp
  # http://devdocs.io/ruby~2.5/string#method-i-unpack
  def read_file(fname)
    File.open(fname) do |f|
      # skip header
      _header = f.read(6)

      logical_screen_descriptor = f.read(7)
      @width, @height, packed_field = logical_screen_descriptor.unpack('SSC')

      # skip color table
      color_table_size = (packed_field & 0b111) + 1
      # TODO use color table to output the correct values, ie 0 for white and 1 for black
      _color_table = f.read(3 * 2**color_table_size)

      # skip image descriptor
      _image_descriptor = f.read(10)

      raw_image_data =
        [].tap do |buf|
          loop do
            byte = f.getbyte
            break if byte == 0
            buf << byte
          end
        end

      @image_data = LZW.decompress(raw_image_data)
    end
  end

  def bin_data
    entity_width = 8

    @image_data
      .each_slice(entity_width)
      .map(&:join)
      .map { |str| str.to_i(2) }
  end
end

class LZW
  # http://www.matthewflickinger.com/lab/whatsinagif/lzw_image_data.asp
  # TODO improve this temporary code
  def self.decompress(data)
    tsize = data.shift
    _bytes_in_block = data.shift
    current_code_size = tsize + 1
    table = Array.new(2**tsize) { |i| [i, [i]] }.to_h
    end_of_information = 2**tsize + 1
    table_new_index = end_of_information + 1

    code = bit_from_stream(data, current_code_size, current_code_size)
    last_code = code
    index_stream = [table[code]]
    bit_index = current_code_size * 2
    code_stream = [code]

    code = bit_from_stream(data, bit_index, current_code_size)
    while code && code != end_of_information && bit_index < data.size * 8
      code_stream << code

      if table.key?(code)
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

    # this .reverse is hacky due the way that values are store inside bytes
    # TODO: use bitwise operations instead of "pack" methods
    data[i, 2].reverse.pack('C*').unpack1('B16')[-offset - size, size]&.to_i(2)
  end
end
