module Pelusa
  module Lint
    class InstanceVariables
      def initialize
        @ivars = Set.new
      end

      def check(klass)
        initialize
        iterate_lines!(klass)

        return SuccessfulAnalysis.new(name) if @ivars.length < limit

        FailedAnalysis.new(name, @ivars) do |ivars|
          "This class uses #{ivars.length} instance variables: #{ivars.to_a.join(', ')}."
        end
      end

      private

      def name
        "Uses less than #{limit} ivars"
      end

      def limit
        3
      end

      def iterate_lines!(klass)
        iterator = Iterator.new do |node|
          if node.is_a?(Rubinius::AST::InstanceVariableAccess) || node.is_a?(Rubinius::AST::InstanceVariableAssignment)
            @ivars << node.name
          end
        end
        Array(klass).each(&iterator)
      end
    end
  end
end
