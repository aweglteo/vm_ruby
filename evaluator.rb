module Vmrb
  class Evaluator
    @stack = []
    @pc = 0
  end

  # sequence is set of instructions
  def evaluate(sequence)
    while ins = sequence[@pc]
      dipatch ins
    end
    @stack[0]
  end

  def dispatch(instruction)
    case instruction.code
    when :nop
    else
      raise "Unknown Opecode: #{instruction}"
    end
    @pc += 1
  end

  def push(object)
    @stack.push(object)
  end

  def pop
    @stack.pop
  end
end
