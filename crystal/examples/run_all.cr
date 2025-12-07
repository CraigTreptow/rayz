# Runner for all Crystal examples
# Port of Ruby's examples/run

require "../src/rayz"

# This file will require all chapter examples once they're ported
# For now, it's a placeholder

module Rayz
  class ExamplesRunner
    def self.run_all
      puts "Crystal Examples Runner"
      puts "=" * 60
      puts "Examples will be added as chapters are ported"
      puts "=" * 60
    end
  end
end

# Run if executed directly
Rayz::ExamplesRunner.run_all if PROGRAM_NAME == __FILE__
