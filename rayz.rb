require_relative "rayz/lib/util"
require_relative "rayz/lib/tuple"
require_relative "rayz/lib/point"

Dir[File.join(__dir__, "{rayz,lib}", "**", "*.rb")].sort.each { |file| require_relative file }

Chapter1.run
Chapter2.run
