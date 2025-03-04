module Rayz
  class Projectile
    attr_accessor :position, :velocity

    def initialize(position:, velocity:)
      @position = position
      @velocity = velocity
    end
  end
end
