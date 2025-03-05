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
    end
  end
end
