require_relative '../lib/entity'
require_relative '../lib/entity_factory'

module Game
  class EntityFactoryTest < Minitest::Test
    def test_extract_entity
      # TODO: add test for multiple line bin
      bin = [
        0b10000111, 0b11001111, 0b00000011,
        0b00110011, 0b00000011, 0b00000011,
        0b10000111, 0b11001111, 0b00000011,
        0b11111111, 0b11111111, 0b11111111
      ]
      factory = EntityFactory.new(bin, cols: 3, entities_count: 3)
      entities = factory.entities
      puts 'printing...'
      puts(entities.map { |entity| Entity.new(entity) })
      puts 'end'
    end

    # def test_entity_factory
    #   bin = [
    #     0b10000111, 0b11001111, 0b00000011,
    #     0b00110011, 0b00000011, 0b00000011,
    #     0b10000111, 0b11001111, 0b00000011,
    #     0b11111111, 0b11111111, 0b11111111
    #   ]
    #   factory = EntityFactory.new(bin, 3, 4, 2)
    #   entities = factory.entities

    #   out, _err = capture_io do
    #     printf("%s\e[%sB", "\n" * entities.first.height, entities.first.height)

    #     entities.each do |entity|
    #       printf("%s\e[%sB", entity, entity.height)
    #     end

    #     printf("\e[%sA", entities.first.height)
    #     printf("\n")
    #   end

    #   assert <<~OUT, out
    #     ▟▀▙
    #     ▝▀▘
    #   OUT
    # end
  end
end
