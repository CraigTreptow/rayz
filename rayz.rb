require_relative "lib/util"
require_relative "lib/tuple"
require_relative "lib/point"

Dir[File.join(__dir__, "{lib,rayz}", "**", "*.rb")].sort.each { |file| require_relative file }

Chapter1.run
Chapter2.run
