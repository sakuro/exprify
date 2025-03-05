# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing a named argument.
    #
    # A named argument node represents a key-value pair in the search expression,
    # typically in the form "name:value". This is used for special search
    # parameters like date ranges or field-specific searches.
    class NamedArgumentNode < Node
      # @return [String] The name of the argument.
      attr_reader :name

      # @return [String] The value of the argument.
      attr_reader :value

      # Initialize a new named argument node.
      #
      # @param name [String] The name of the argument.
      # @param value [String] The value of the argument.
      # @return [NamedArgumentNode] A new instance of NamedArgumentNode.
      def initialize(name, value)
        super()
        @name = name
        @value = value
      end

      # Accept a transformer.
      #
      # Dispatches to the transformer's transform_named_argument method with self as the argument.
      #
      # @param transformer [Exprify::Transformers::Base] The transformer object that implements transform_named_argument.
      # @return [Object] The result of the transform operation.
      def accept(transformer)
        transformer.transform_named_argument(self)
      end

      # Return a string representation of the node.
      #
      # @return [String] The string representation containing the node's class name, name, and value.
      def inspect
        "#<NamedArgumentNode name=#{name.inspect} value=#{value.inspect}>"
      end

      # Pretty print the node.
      #
      # Outputs a human-readable representation of the node and its name and value
      # using Ruby's pretty print facility.
      #
      # @param pp [PP] The pretty printer instance.
      # @return [void]
      def pretty_print(pp)
        super
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
