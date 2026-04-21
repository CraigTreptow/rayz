module Rayz
  class Material
    attr_accessor :color, :ambient, :diffuse, :specular, :shininess, :reflective, :transparency, :refractive_index, :pattern, :normal_perturbation

    def initialize
      @color = Color.new(red: 1, green: 1, blue: 1)
      @ambient = 0.1
      @diffuse = 0.9
      @specular = 0.9
      @shininess = 200.0
      @reflective = 0.0
      @transparency = 0.0
      @refractive_index = 1.0
      @pattern = nil
      @normal_perturbation = nil  # Proc that takes (point) -> Vector to add to normal
    end

    def ==(other)
      @color == other.color &&
        @ambient == other.ambient &&
        @diffuse == other.diffuse &&
        @specular == other.specular &&
        @shininess == other.shininess &&
        @reflective == other.reflective &&
        @transparency == other.transparency &&
        @refractive_index == other.refractive_index
    end
  end
end
