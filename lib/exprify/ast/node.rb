# frozen_string_literal: true

require "pp"

module Exprify
  module AST
    # Base class for all AST nodes
    class Node
      # Accept a visitor and dispatch to the appropriate visit method
      #
      # @param visitor [Object] The visitor object
      # @return [Object] The result of the visit
      def accept(visitor)
        raise NotImplementedError
      end

      # Return a string representation of the node
      #
      # @return [String] The string representation
      def inspect
        "#<#{self.class.name.split("::").last}>"
      end

      # Pretty print the node
      #
      # @param pp [PP] The pretty printer
      # @return [void]
      def pretty_print(pp)
        pp.text(self.class.name.split("::").last)
      end

      # Pretty print an array of child nodes
      #
      # @param pp [PP] The pretty printer
      # @param label [String] The label for the array
      # @param children [Array<Node>] The child nodes to print
      # @return [void]
      private def pretty_print_children(pp, label, children)
        pp.nest(2) do
          pp.breakable
          pp.text("#{label}: [")
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
