class Point
  include Comparable

  alias eql? ==

  def self.from_index(idx, width)
    new(idx / width, idx % width)
  end

  attr_reader :x, :y

  def initialize(*args)
    @x, @y = args.flatten
  end

  def +(other)
    self.class.new(x + other.x, y + other.y)
  end

  def -(other)
    self.class.new(x - other.x, y - other.y)
  end

  def <=>(other)
    return -1 if x < other.x
    return -1 if x == other.x && y < other.y
    return 0 if x == other.x && y == other.y
    1
  end

  def to_s
    "Point[#{x},#{y}]"
  end

  def inspect
    "Point[#{x},#{y}]"
  end

  def hash
    [x, y].hash
  end

  def to_a
    [x, y]
  end

  def rotate(turns)
    self.class.new(*(Complex(x, y) * (Complex(0, 1)**turns)).rect)
  end
end
