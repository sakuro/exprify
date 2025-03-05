# frozen_string_literal: true

require "pp"

module Exprify
  module AST
    # Base class for all AST nodes.
    class Node
      # Accept a transformer and dispatch to the appropriate transform method.
      #
      # This is an implementation of the visitor pattern that allows operations
      # to be performed on the AST without modifying the node classes.
      #
      # @param transformer [Exprify::Transformers::Base] The transformer object that implements transform_* methods.
      # @return [Object] The result of the transform operation.
      def accept(transformer)
        raise NotImplementedError
      end

      # Return a string representation of the node.
      #
      # @return [String] The string representation containing the node's class name.
      def inspect
        "#<#{self.class.name.split("::").last}>"
      end

      # Pretty print the node.
      #
      # Outputs a human-readable representation of the node using
      # Ruby's pretty print facility.
      #
      # @param pp [PP] The pretty printer instance.
      # @return [void]
      def pretty_print(pp)
        pp.text(self.class.name.split("::").last)
      end

      # Pretty print an array of child nodes.
      #
      # Formats child nodes with proper indentation and separators
      # for improved readability.
      #
      # @param pp [PP] The pretty printer instance.
      # @param label [String] The label for the array of children.
      # @param children [Array<Node>] The child nodes to print.
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
