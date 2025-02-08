class Color
  attr_reader :red, :green, :blue

  def initialize(red:, green:, blue:)
    @red = red
    @green = green
    @blue = blue
  end

  def +(other)
    Color.new(red: @red + other.red, green: @green + other.green, blue: @blue + other.blue)
  end

  def -(other)
    Color.new(red: @red - other.red, green: @green - other.green, blue: @blue - other.blue)
  end

  def *(other)
    case other
    in Float
      Color.new(red: @red * other, green: @green * other, blue: @blue * other)
    in Color
      Color.new(red: @red * other.red, green: @green * other.green, blue: @blue * other.blue)
    else
      raise "Unknown type: #{other.class}"
    end
  end

  # these are required to allow the pattern matching above to work
  # https://docs.ruby-lang.org/en/master/syntax/pattern_matching_rdoc.html#label-Matching+non-primitive+objects-3A+deconstruct+and+deconstruct_keys

  def deconstruct
    [@red, @green, @blue]
  end

  def deconstruct_keys(keys)
    {red: @red, green: @green, blue: @blue}
  end

  def to_s
    "Class: #{self.class.name} Red: #{@red} Green: #{@green} Blue: #{@blue}"
  end

  # rubocop:disable Style/YodaCondition
  # rubocop:disable Lint/Void
  def ==(other)
    Util.==(@red, other.red)
    Util.==(@green, other.green)
    Util.==(@blue, other.blue)
  end
  # rubocop:enable Lint/Void
  # rubocop:enable Style/YodaCondition
end
