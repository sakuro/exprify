# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing a NOT operation.
    #
    # A NOT node represents a logical negation of a search term,
    # where the expression must not match for the NOT operation to succeed.
    class NotNode < Node
      # @return [Node] The expression to negate.
      attr_reader :expression

      # Initialize a new NOT node.
      #
      # @param expression [Node] The expression to negate.
      # @return [NotNode] A new instance of NotNode.
      def initialize(expression)
        super()
        @expression = expression
      end

      # Accept a transformer.
      #
      # Dispatches to the transformer's transform_not method with self as the argument.
      #
      # @param transformer [Exprify::Transformers::Base] The transformer object that implements transform_not.
      # @return [Object] The result of the transform operation.
      def accept(transformer)
        transformer.transform_not(self)
      end

      # Return a string representation of the node.
      #
      # @return [String] The string representation containing the node's class name and expression.
      def inspect
        "#<NotNode expression=#{expression.inspect}>"
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
