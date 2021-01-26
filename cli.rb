require 'optparse'

require_relative 'evaluator'
require_relative 'instruction'

module Vmrb
  class CLI
    def initialize(argv)
      @argv = ARGV
      parse_option
    end

    def run
      exit 0 if @program.nil?
      puts @program
    end

    private

    def parse_option
      @parser = OptionParser.new do |o|
        o.on "-t", "--target program", "exec target program" do |arg|
          @program = arg
        end
      end
      @parser.parse(@argv)
    end
  end
end
