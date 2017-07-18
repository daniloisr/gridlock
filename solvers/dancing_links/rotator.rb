class Rotator
  def self.rotate((width, piece_body), turns = 1)
    height = piece_body.size / width
    result = Array.new([height, width].max**2)
    new_width, translate_index =
      case turns
      when 0 then [width,  [0, 0]]
      when 1 then [height, [0, width]]
      when 2 then [width,  [height, width]]
      when 3 then [height, [height, 0]]
      end

    translate = Complex(*translate_index)

    (0...height).each do |i|
      (0...width).each do |j|
        rotated = (Complex(i, j) - translate) * 1i**turns
        index = rotated.real * width + rotated.imaginary

        result[index] = piece_body[i * width + j] || '_'
      end
    end

    [new_width, result.join]
  end

  def initialize(piece)
    @piece = piece
  end

  def rotations
    Array.new(4) { |turn| self.class.rotate(@piece, turn) }
  end
end
