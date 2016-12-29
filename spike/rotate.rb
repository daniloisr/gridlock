require 'minitest/autorun'

class RotateTest < Minitest::Test
  def test_rotate_2x1
    piece = [2, 'ab']

    assert_equal [1, 'ba'], rotate(piece, 1)
    assert_equal [2, 'ba'], rotate(piece, 2)
    assert_equal [1, 'ab'], rotate(piece, 3)
  end

  def test_rotate_2x2
    piece = [2, 'abcd']

    assert_equal [2, 'bdac'], rotate(piece, 1)
    assert_equal [2, 'dcba'], rotate(piece, 2)
    assert_equal [2, 'cadb'], rotate(piece, 3)
  end

  def test_rotate_2x2_L_shape
    piece = [2, 'abcd']
    piece = [2, 'abc_']

    assert_equal [2, 'b_ac'], rotate(piece, 1)
    assert_equal [2, '_cba'], rotate(piece, 2)
    assert_equal [2, 'ca_b'], rotate(piece, 3)
  end

  def rotate((width, piece_body), turns = 1)
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
end
