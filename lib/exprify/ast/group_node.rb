# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing a grouped expression.
    #
    # A group node represents a parenthesized expression in the input,
    # which controls operator precedence in the search expression.
    class GroupNode < Node
      # @return [Node] The expression within the group.
      attr_reader :expression

      # Initialize a new group node.
      #
      # @param expression [Node] The expression within the group.
      # @return [GroupNode] A new instance of GroupNode.
      def initialize(expression)
        super()
        @expression = expression
      end

      # Accept a transformer.
      #
      # Dispatches to the transformer's transform_group method with self as the argument.
      #
      # @param transformer [Exprify::Transformers::Base] The transformer object that implements transform_group.
      # @return [Object] The result of the transform operation.
      def accept(transformer)
        transformer.transform_group(self)
      end

      # Return a string representation of the node.
      #
      # @return [String] The string representation containing the node's class name and expression.
      def inspect
        "#<GroupNode expression=#{expression.inspect}>"
      end

      # Pretty print the node.
      #
      # Outputs a human-readable representation of the node and its expression
      # using Ruby's pretty print facility.
      #
      # @param pp [PP] The pretty printer instance.
      # @return [void]
      def pretty_print(pp)
        super
        pp.nest(2) do
          pp.breakable
          pp.text("expression: ")
          expression.pretty_print(pp)
        end
      end
    end
  end
end
