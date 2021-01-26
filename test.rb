require "pry"

module RubyOriginalVM
  class Fuga
    attr_reader :bytecode, :stack

    def initialize
      @bytecode = RubyVM::InstructionSequence.compile_file("sample.rb", false).to_a
      @stack = []
      @main = generate_main
    end

    def run
      @bytecode.to_a.last.each do |instruction|
        next unless instruction.is_a?(Array)
        execute(instruction)
      end 
    end

    def execute(instruction)
      opecode = instruction[0]
      operand = instruction[1..-1]
      # puts "instruction: #{opecode}(#{operand&.join(", ")})"

      case opecode
      when :putself
        push @main
      when :putstring
        push operand[0]
      when :send
        call_info = operand[0]
        args = Array.new(call_info[:orig_argc]) { pop }.reverse
        receiver = pop
        push receiver.send(call_info[:mid], *args)
      when :leave
        #nop
      end

      # puts "====== stack: #{@stack}"
    end

    def push(val)
      @stack.push(val)
    end

    def pop
      @stack.pop
    end

    def generate_main
      main = Object.new
      class << main
        def to_s
          "main"
        end
        alias inspect to_s
      end
      main
    end

  end
end


vm = RubyOriginalVM::Fuga.new
vm.run