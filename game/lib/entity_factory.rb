module Game
  class EntityFactory
    ENTITY_WIDTH  = 8
    ENTITY_HEIGHT = 4

    def initialize(bin, entity_width, entity_height)
      @bin = bin
      @entity_width = entity_width
      @entity_height = entity_height
    end

    def entities
      extract_entity(0)
    end

    def extract_entity(_pos)
      Array.new(4) { |i| @bin[i * 3] }
    end

    # bin = [
    #   0b10000111, 0b11001111, 0b00000011,
    #   0b00110011, 0b00000011, 0b00000011,
    #   0b10000111, 0b11001111, 0b00000011,
    #   0b11111111, 0b11111111, 0b11111111
    # ]
    def extract_entity2(pos)
      character_width = 2
      # number of entities in the @bin variable
      bin_entities = 3

      (ENTITY_HEIGHT / character_width).times.flat_map do |i|
        bit_a = @bin[pos + bin_entities * i * 2]
        bit_b = @bin[pos + bin_entities + bin_entities * i * 2]

        Array.new(ENTITY_WIDTH / character_width) do |j|
          bit_offset = ENTITY_WIDTH - (j + 1) * 2
          mask = 0b11
          first_pair  = ((bit_a >> bit_offset & mask) << 2)
          second_pair =  (bit_b >> bit_offset & mask)
          first_pair + second_pair
        end
      end
    end
  end
end
