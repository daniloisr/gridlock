require 'entity'

module Game
  class EntityTest < Minitest::Test
    SAMPLE_DATA = [
      0b01111000,
      0b11001100,
      0b01111000,
      0b00000000
    ].freeze

    def test_to_s
      entity = Entity.new(SAMPLE_DATA)
      out, _err = capture_io do
        printf("%s\e[%sB%s\n", "\n" * entity.height, entity.height, entity)
      end

      assert <<~ENTITY_OUT, out
        ▟▀▙
        ▝▀▘
      ENTITY_OUT
    end
  end
end
