#!/usr/bin/env ruby

require_relative "../lib/rayz"
require_relative "chapter1"
require_relative "chapter2"
require_relative "chapter3"
require_relative "chapter4"
require_relative "chapter5"
require_relative "chapter6"
require_relative "chapter7"
require_relative "chapter8"
require_relative "chapter9"
require_relative "chapter10"
require_relative "chapter11"
require_relative "chapter12"
require_relative "chapter13"
require_relative "chapter14"
require_relative "chapter15"

module Rayz
  class ExamplesRunner
    CHAPTERS = {
      1 => Chapter1,
      2 => Chapter2,
      3 => Chapter3,
      4 => Chapter4,
      5 => Chapter5,
      6 => Chapter6,
      7 => Chapter7,
      8 => Chapter8,
      9 => Chapter9,
      10 => Chapter10,
      11 => Chapter11,
      12 => Chapter12,
      13 => Chapter13,
      14 => Chapter14,
      15 => Chapter15
    }

    def self.run_all
      CHAPTERS.keys.sort.each do |chapter_num|
        CHAPTERS[chapter_num].run
      end
    end

    def self.run_chapter(num)
      chapter = CHAPTERS[num]
      if chapter
        chapter.run
      else
        puts "Error: Chapter #{num} does not exist."
        puts "Available chapters: 1-#{CHAPTERS.keys.max}"
        exit 1
      end
    end

    def self.usage
      puts "Usage: ruby examples/run.rb [all|<chapter_number>]"
      puts ""
      puts "Examples:"
      puts "  ruby examples/run.rb all    # Run all chapters (1-15)"
      puts "  ruby examples/run.rb 4      # Run only chapter 4"
      puts "  ruby examples/run.rb        # Run all chapters (default)"
      puts ""
      puts "Available chapters: 1-#{CHAPTERS.keys.max}"
    end

    def self.parse_and_run(args)
      if args.empty? || args.first == "all"
        run_all
      elsif args.first =~ /^\d+$/
        chapter_num = args.first.to_i
        run_chapter(chapter_num)
      else
        usage
        exit 1
      end
    end
  end
end

if __FILE__ == $0
  Rayz::ExamplesRunner.parse_and_run(ARGV)
end
