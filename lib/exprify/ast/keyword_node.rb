# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing a keyword
    class KeywordNode < Node
      # @return [String] The keyword value
      attr_reader :value

      # Initialize a new keyword node
      #
      # @param value [String] The keyword value
      # @return [KeywordNode] A new keyword node
      def initialize(value)
        super()
        @value = value
      end

      # Accept a visitor
      #
      # @param visitor [Object] The visitor object
      # @return [Object] The result of the visit
      def accept(visitor)
        visitor.visit_keyword(self)
      end

      # Return a string representation of the node
      #
      # @return [String] The string representation
      def inspect
        "#<KeywordNode value=#{value.inspect}>"
      end

      # Pretty print the node
      #
      # @param pp [PP] The pretty printer
      # @return [void]
      def pretty_print(pp)
        pp.text("KeywordNode")
        pp.nest(2) do
          pp.breakable
          pp.text("value: ")
          pp.pp(value)
        end
      end
    end
  end
end
