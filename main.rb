#
# RubiMaVM
#

require "pry"

module RubiMaVM
    class Instruction
      # 命令列はこれにmapされる。
      # opts = 配列になる。n
      def initialize code, opts
        @code = code
        @opts = opts
      end
      attr_reader :code, :opts
  
      def inspect
        "#{code} <#{opts.join ', '}>"
      end
    end
    
    # Labelのposてんやろ。n
    class Label
      @@id = 0
      def initialize label
        @label = label
        @pos = -1
        @id  = @@id+=1
      end
      attr_accessor :pos
  
      def inspect
        "#{@label} <#{@id}@#{@pos}>"
      end
      alias to_s inspect
    end
  
    class Evaluator
      def initialize
        @stack = []
        @pc    = 0
      end
  
      def evaluate sequence
        while insn = sequence[@pc]
          binding.pry
          dispatch insn
        end
        @stack[0]
      end
  
      def dispatch insn
        begin
          case insn.code
          when :nop
    
          when :push
            push insn.opts[0]
    
          when :pop
            pop
    
          when :dup
            popped = pop
            push popped
            push popped
    
          when :add
            push pop + pop
    
          when :sub
            push pop - pop
    
          when :mul
            push pop * pop
    
          when :div
            push pop / pop
    
          when :not
            push !pop
    
          when :smaller
            push pop < pop
    
          when :bigger
            push pop > pop
    
          when :goto
            @pc = insn.opts[0].pos
            return
          
          # if文章の場合、戻る
          when :if
            if pop
              @pc = insn.opts[0].pos
              return
            end
    
          else
            raise "Unknown Opcode: #{insn}"
          end
    
          @pc += 1
        rescue
        end
      end
  
      def push obj
        @stack.push obj
      end
      
      # @stack
      def pop
        @stack.pop
      end
    end
    
    # result
    # [push <1>, add <>, dup <>, push <100000>, bigger <>, if <:label <1@1>>]
    class Parser
      def self.parse program
        pc     = 0
        labels = {}
        
        program.split(/\R/).map{|line|
          p line
          line = line.strip
          insn = []

          # :始まりで、\wが1回以上続き、末尾にmatchするなら
          # これがlabelが入力された場合
          if /\A:\w+\z/ =~ line
            label = $~[0].intern
            unless lobj = labels[label]
              lobj  = ::RubiMaVM::Label.new label
              labels[label] = lobj
            end
            next lobj
          end
  
          while line.size > 0
            case line
            when /\A:[a-z]+/
              # label
              label = $~[0].intern
              unless lobj = labels[label]
                lobj = ::RubiMaVM::Label.new label
                labels[label] = lobj
              end
              insn << lobj
  
            when /\A\s+/, /\A\#.*/
              # ignore  
            
            #   普通の命令の場合
            when /\A[a-z]+/
              insn << $~[0].intern
            
            # 数字の場合
            when /\A\d+/
              insn << $~[0].to_i
  
            else
              raise "Parse Error: #{line}"
  
            end
            line = $~.post_match
          end
  
          insn.size > 0 ? insn : nil
        }.compact.map{|insn|
          if insn.kind_of? ::RubiMaVM::Label
            insn.pos = pc
            nil
          else
            pc += 1
            ::RubiMaVM::Instruction.new insn[0], insn[1..-1]
          end
        }.compact
      end
    end
  end
  
  
  if $0 == __FILE__
    program = File.read("./sample.vmrb")
  
    parsed_program = RubiMaVM::Parser.parse program
    # binding.pry

    # parsed_program.each_with_index{|insn, idx|
    #   puts "#{'%04d' % idx}\t#{insn.inspect}"
    # }
  
    result = RubiMaVM::Evaluator.new.evaluate parsed_program
    puts result
  end