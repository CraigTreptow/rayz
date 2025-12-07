# Runner for all Crystal examples
# Port of Ruby's examples/run

require "../src/rayz"

module Rayz
  class ExamplesRunner
    # TODO: Add chapters as they're ported
    CHAPTERS = {} of Int32 => String
    DEMOS = {} of String => String

    def self.run_all
      if CHAPTERS.empty?
        puts "\n" + ("=" * 60)
        puts "Crystal Port - No chapters implemented yet"
        puts ("=" * 60)
        puts "\nImplemented: Core math classes (Tuple, Point, Vector, Color, Canvas)"
        puts "Next: Matrix, Transformations, then Chapters 1-17"
        puts "\nRun './rayz crystal' to see what's working"
        puts ("=" * 60) + "\n"
      else
        CHAPTERS.keys.sort.each do |chapter_num|
          # Will run chapters when implemented
        end

        DEMOS.keys.sort.each do |demo_name|
          # Will run demos when implemented
        end
      end
    end

    def self.run_chapter(num : Int32)
      if CHAPTERS.has_key?(num)
        puts "Running Chapter #{num}..."
        # Will implement when chapters are ported
      else
        puts "\nError: Chapter #{num} not yet implemented in Crystal"
        puts "Available chapters: #{CHAPTERS.keys.sort.join(", ")}" unless CHAPTERS.empty?
        puts "Currently implemented: none (port in progress)"
        puts "\nTo see what's working, run: ./rayz crystal"
        exit 1
      end
    end

    def self.run_demo(name : String)
      if DEMOS.has_key?(name)
        puts "Running demo: #{name}..."
        # Will implement when demos are ported
      else
        puts "\nError: Demo '#{name}' not yet implemented in Crystal"
        puts "Available demos: #{DEMOS.keys.sort.join(", ")}" unless DEMOS.empty?
        puts "Currently implemented: none (port in progress)"
        exit 1
      end
    end

    def self.usage
      puts "Usage: crystal run examples/run_all.cr [all|<chapter_number>|<demo_name>]"
      puts ""
      puts "Examples:"
      puts "  ./rayz crystal all              # Run all chapters and demos"
      puts "  ./rayz crystal 4                # Run only chapter 4"
      puts "  ./rayz crystal obj_parser       # Run OBJ parser demo"
      puts "  ./rayz crystal                  # Show current status"
      puts ""
      if CHAPTERS.empty?
        puts "Available chapters: none (port in progress)"
      else
        puts "Available chapters: #{CHAPTERS.keys.sort.join(", ")}"
      end
      if DEMOS.empty?
        puts "Available demos: none (port in progress)"
      else
        puts "Available demos: #{DEMOS.keys.sort.join(", ")}"
      end
    end

    def self.parse_and_run(args : Array(String))
      if args.empty?
        # Show status when no args
        Rayz.demo
      elsif args.first == "all"
        run_all
      elsif args.first =~ /^\d+$/
        chapter_num = args.first.to_i
        run_chapter(chapter_num)
      elsif DEMOS.has_key?(args.first)
        run_demo(args.first)
      else
        usage
        exit 1
      end
    end
  end
end

# Run if executed directly
if PROGRAM_NAME.includes?("run_all")
  Rayz::ExamplesRunner.parse_and_run(ARGV)
end
