# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing an OR operation.
    #
    # An OR node represents a logical disjunction of multiple search terms,
    # where at least one child node must match for the OR operation to succeed.
    class OrNode < Node
      # @return [Array<Node>] The child nodes where at least one must match.
      attr_reader :children

      # Initialize a new OR node.
      #
      # @param children [Array<Node>] The child nodes where at least one must match.
      # @return [OrNode] A new instance of OrNode.
      def initialize(*children)
        super()
        @children = children
      end

      # Accept a transformer.
      #
      # Dispatches to the transformer's transform_or method with self as the argument.
      #
      # @param transformer [Exprify::Transformers::Base] The transformer object that implements transform_or.
      # @return [Object] The result of the transform operation.
      def accept(transformer)
        transformer.transform_or(self)
      end

      # Return a string representation of the node.
      #
      # @return [String] The string representation containing the node's class name and children.
      def inspect
        "#<OrNode children=[#{children.map(&:inspect).join(", ")}]>"
      end

      # Pretty print the node.
      #
      # Outputs a human-readable representation of the node and its children
      # using Ruby's pretty print facility.
      #
      # @param pp [PP] The pretty printer instance.
      # @return [void]
      def pretty_print(pp)
        super
        pretty_print_children(pp, "children", children)
      end
    end
  end
end
