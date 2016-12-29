require 'minitest/autorun'
require 'rotate'

class RotateTest < Minitest::Test
  def rotate(*args)
    Rotator.rotate(*args)
  end

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
end
