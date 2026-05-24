module Rayz
  class Material
    property color : Color
    property ambient : Float64
    property diffuse : Float64
    property specular : Float64
    property shininess : Float64
    property reflective : Float64
    property transparency : Float64
    property refractive_index : Float64

    def initialize
      @color = Color.new(1.0, 1.0, 1.0)
      @ambient = 0.1
      @diffuse = 0.9
      @specular = 0.9
      @shininess = 200.0
      @reflective = 0.0
      @transparency = 0.0
      @refractive_index = 1.0
    end

    def ==(other : Material) : Bool
      @color == other.color &&
        Util.approx_eq?(@ambient, other.ambient) &&
        Util.approx_eq?(@diffuse, other.diffuse) &&
        Util.approx_eq?(@specular, other.specular) &&
        Util.approx_eq?(@shininess, other.shininess) &&
        Util.approx_eq?(@reflective, other.reflective) &&
        Util.approx_eq?(@transparency, other.transparency) &&
        Util.approx_eq?(@refractive_index, other.refractive_index)
    end
  end
end
