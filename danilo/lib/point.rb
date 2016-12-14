class Point
  include Comparable

  alias eql? ==

  def self.from_index(idx, width)
    new(idx / width, idx % width)
  end

  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
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
end
