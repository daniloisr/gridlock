require 'minitest/autorun'
require 'byebug'

module Game
  class Entity
    # https://en.wikipedia.org/wiki/Block_Elements#Character_table
    # rubocop:disable Style/AsciiComments
    CHARACTER_MAP = {
      0b0000 => ' ',
      0b1111 => "\u2588", # █ full block
      0b1000 => "\u2598", # ▘ upper left
      0b0100 => "\u259D", # ▝ upper right
      0b0010 => "\u2596", # ▖ lower left
      0b0001 => "\u2597", # ▗ lower right
      0b1100 => "\u2580", # ▀ upper half block
      0b0101 => "\u2590", # ▐ right half block
      0b0011 => "\u2584", # ▄ lower half block
      0b1010 => "\u258C", # ▌ left half block
      0b1110 => "\u259B", # ▛ upper left and upper right and lower left
      0b1101 => "\u259C", # ▜ upper left and upper right and lower right
      0b1011 => "\u2599", # ▙ upper left and lower left and lower right
      0b0111 => "\u259F", # ▟ upper right and lower left and lower right
      0b1001 => "\u259A", # ▚ upper left and lower right
      0b0110 => "\u259E", # ▞ upper right and lower left
    }.freeze
    # rubocop:enable Style/AsciiComments

    attr_reader :height, :width

    def initialize(data)
      @width = 4
      @height = 2
      @data = data
    end

    def to_s
      Array.new(@height) do |row|
        Array.new(@width) { |col| character_at(row, col) }.join
      end.join(move_cursor_to_next_line)
    end

    private

    BIT_DIMENSION = 2
    BIT_MASK = 0b11

    def character_at(row, col)
      offset = @width * BIT_DIMENSION - col * BIT_DIMENSION - BIT_DIMENSION
      character_val =
        @data[row * BIT_DIMENSION, BIT_DIMENSION]
        .reduce(0) do |sum, byte|
          sum + (byte >> offset & BIT_MASK) << BIT_DIMENSION
        end

      CHARACTER_MAP[character_val >> BIT_DIMENSION]
    end

    def move_cursor_to_next_line
      "\n\e[#{@width}D"
    end
  end
end
