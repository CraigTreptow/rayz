# Main entry point for the Rayz ray tracer library (Crystal implementation)
#
# This file requires all the core components of the ray tracer.
# Port of the Ruby implementation from lib/rayz.rb

require "./rayz/util"
require "./rayz/tuple"
require "./rayz/point"
require "./rayz/vector"
require "./rayz/color"
require "./rayz/canvas"
# require "./rayz/matrix"
# require "./rayz/transformations"

module Rayz
  VERSION = "0.1.0"
end
