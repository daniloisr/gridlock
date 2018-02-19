require 'minitest/autorun'
require 'byebug'

module Game
  class EntityFactory
    def initialize(bin, entity_width, entity_height)
      @bin = bin
      @entity_width = entity_width
      @entity_height = entity_height
    end

    def entities
      # bin_dimension = 2

      @bin
    end
  end

  class EntityFactoryTest < Minitest::Test
    def test_entity_factory
      bin = <<~BIN.each_slice(8).map(&:join).map { |str| str.to_i(2) }
        100001111100111100000011
        001100110000001100000011
        100001111100111100000011
        111111111111111111111111
      BIN
      factory = EntityFactory.new(bin, 4, 2)
      entities = factory.entities

      out, _err = capture_io do
        printf("%s\e[%sB", "\n" * entities.first.height, entities.first.height)

        entities.each do |entity|
          printf("%s\e[%sB", entity, entity.height)
        end

        printf("\e[%sA", entities.first.height)
        printf("\n")
      end

      assert <<~OUT, out
        ▟▀▙
        ▝▀▘
      OUT
    end
  end
end
