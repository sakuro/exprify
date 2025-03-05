# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing a named argument with a name and value
    class NamedArgumentNode < Node
      # @return [String] The argument name
      attr_reader :name
      # @return [String] The argument value
      attr_reader :value

      # Initialize a new named argument node
      #
      # @param name [String] The argument name
      # @param value [String] The argument value
      # @return [NamedArgumentNode] A new named argument node
      def initialize(name, value)
        super()
        @name = name
        @value = value
      end

      # Accept a visitor
      #
      # @param visitor [Object] The visitor object
      # @return [Object] The result of the visit
      def accept(visitor)
        visitor.visit_named_argument(self)
      end

      # Return a string representation of the node
      #
      # @return [String] The string representation
      def inspect
        "#<NamedArgumentNode name=#{name.inspect} value=#{value.inspect}>"
      end

      # Pretty print the node
      #
      # @param pp [PP] The pretty printer
      # @return [void]
      def pretty_print(pp)
        pp.text("NamedArgumentNode")
        pp.nest(2) do
          pp.breakable
          pp.text("name: ")
          pp.pp(name)
          pp.breakable
          pp.text("value: ")
          pp.pp(value)
        end
      end
    end
  end
end
