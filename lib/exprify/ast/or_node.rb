# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing an OR operation
    class OrNode < Node
      # @return [Array<Node>] The child nodes
      attr_reader :children

      # Initialize a new OR node
      #
      # @param children [Array<Node>] The child nodes
      # @return [OrNode] A new OR node
      def initialize(*children)
        super()
        @children = children
      end

      # Accept a visitor
      #
      # @param visitor [Object] The visitor object
      # @return [Object] The result of the visit
      def accept(visitor)
        visitor.visit_or(self)
      end

      # Return a string representation of the node
      #
      # @return [String] The string representation
      def inspect
        "#<OrNode children=[#{children.map(&:inspect).join(", ")}]>"
      end

      # Pretty print the node
      #
      # @param pp [PP] The pretty printer
      # @return [void]
      def pretty_print(pp)
        pp.text("OrNode")
        pp.nest(2) do
          pp.breakable
          pp.text("children: [")
          pp.nest(2) do
            children.each_with_index do |child, index|
              pp.breakable
              child.pretty_print(pp)
              pp.text(",") if index < children.size - 1
            end
          end
          pp.breakable
          pp.text("]")
        end
      end
    end
  end
end
