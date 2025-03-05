# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing an AND operation
    class AndNode < Node
      # @return [Array<Node>] The child nodes
      attr_reader :children

      # Initialize a new AND node
      #
      # @param children [Array<Node>] The child nodes
      # @return [AndNode] A new AND node
      def initialize(*children)
        super()
        @children = children
      end

      # Accept a visitor
      #
      # @param visitor [Object] The visitor object
      # @return [Object] The result of the visit
      def accept(visitor)
        visitor.visit_and(self)
      end

      # Return a string representation of the node
      #
      # @return [String] The string representation
      def inspect
        "#<AndNode children=[#{children.map(&:inspect).join(", ")}]>"
      end

      # Pretty print the node
      #
      # @param pp [PP] The pretty printer
      # @return [void]
      def pretty_print(pp)
        super
        pretty_print_children(pp, "children", children)
      end
    end
  end
end
