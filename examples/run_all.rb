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
    def self.run
      Chapter1.run
      Chapter2.run
      Chapter3.run
      Chapter4.run
      Chapter5.run
      Chapter6.run
      Chapter7.run
      Chapter8.run
      Chapter9.run
      Chapter10.run
      Chapter11.run
      Chapter12.run
      Chapter13.run
      Chapter14.run
      Chapter15.run
    end
  end
end

if __FILE__ == $0
  Rayz::ExamplesRunner.run
end
