# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing a grouped expression
    class GroupNode < Node
      # @return [Node] The grouped expression
      attr_reader :expression

      # Initialize a new group node
      #
      # @param expression [Node] The grouped expression
      # @return [GroupNode] A new group node
      def initialize(expression)
        super()
        @expression = expression
      end

      # Accept a visitor
      #
      # @param visitor [Object] The visitor object
      # @return [Object] The result of the visit
      def accept(visitor)
        visitor.visit_group(self)
      end

      # Return a string representation of the node
      #
      # @return [String] The string representation
      def inspect
        "#<GroupNode expression=#{expression.inspect}>"
      end

      # Pretty print the node
      #
      # @param pp [PP] The pretty printer
      # @return [void]
      def pretty_print(pp)
        pp.text("GroupNode")
        pp.nest(2) do
          pp.breakable
          pp.text("expression: ")
          expression.pretty_print(pp)
        end
      end
    end
  end
end
