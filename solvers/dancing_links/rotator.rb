class Rotator
  def self.rotate((width, piece_body), turns = 1)
    height = piece_body.size / width
    result = Array.new([height, width].max ** 2)
    new_width, translate_index =
      [
        [width,  [0, 0]],
        [height, [0, width]],
        [width,  [height, width]],
        [height, [height, 0]]
      ][turns]

    translate = Complex(*translate_index)

    for i in 0...height
      for j in 0...width
        rotated = (Complex(i, j) - translate) * 1i ** turns
        index = rotated.real * width + rotated.imaginary

        result[index] = piece_body[i * width + j] || _
      end
    end

    [new_width, result.join]
  end

  def initializer(piece)
    @piece = piece
  end

  def rotations
    Array.new(4).map { |turn| self.class.rotate(piece.el, turn) }
  end
end
