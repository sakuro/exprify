# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing an AND operation.
    #
    # An AND node represents a logical conjunction of multiple search terms,
    # where all child nodes must match for the AND operation to succeed.
    class AndNode < Node
      # @return [Array<Node>] The child nodes that must all match.
      attr_reader :children

      # Initialize a new AND node.
      #
      # @param children [Array<Node>] The child nodes that must all match.
      # @return [AndNode] A new instance of AndNode.
      def initialize(*children)
        super()
        @children = children
      end

      # Accept a transformer.
      #
      # Dispatches to the transformer's transform_and method with self as the argument.
      #
      # @param transformer [Exprify::Transformers::Base] The transformer object that implements transform_and.
      # @return [Object] The result of the transform operation.
      def accept(transformer)
        transformer.transform_and(self)
      end

      # Return a string representation of the node.
      #
      # @return [String] The string representation containing the node's class name and children.
      def inspect
        "#<AndNode children=[#{children.map(&:inspect).join(", ")}]>"
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
