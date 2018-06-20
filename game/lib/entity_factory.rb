module Game
  class EntityFactory
    def initialize(bin, cols:, entities_count:)
      @bin = bin
      @cols = cols
      @entities_count = entities_count
    end

    def entities
      Array.new(@entities_count) { |i| extract_entity(i) }
    end

    # bin = [
    #   0b10000111, 0b11001111, 0b00000011,
    #   0b00110011, 0b00000011, 0b00000011,
    #   0b10000111, 0b11001111, 0b00000011,
    #   0b11111111, 0b11111111, 0b11111111
    # ]
    def extract_entity(pos)
      entity_byte = 4
      Array.new(entity_byte) { |i| @bin[i * @cols + pos] }
    end
  end
end
