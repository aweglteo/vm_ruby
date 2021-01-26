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
      exit 0 if @path.nil?
      @program = File.read(@path)
    end

    private

    def parse_option
      @parser = OptionParser.new do |o|
        o.on "-t", "--target program", "exec target program" do |arg|
          @path = arg
        end
      end
      @parser.parse(@argv)
    end
  end
end
