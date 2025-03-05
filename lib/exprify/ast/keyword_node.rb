# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing a keyword
    class KeywordNode < Node
      # @return [String] The keyword value
      attr_reader :value

      # Initialize a new keyword node
      #
      # @param value [String] The keyword value
      # @return [KeywordNode] A new keyword node
      def initialize(value)
        super()
        @value = value
      end

      # Accept a transformer.
      #
      # Dispatches to the transformer's transform_keyword method with self as the argument.
      #
      # @param transformer [Exprify::Transformers::Base] The transformer object that implements transform_keyword.
      # @return [Object] The result of the transform operation.
      def accept(transformer)
        transformer.transform_keyword(self)
      end

      # Return a string representation of the node
      #
      # @return [String] The string representation
      def inspect
        "#<KeywordNode value=#{value.inspect}>"
      end

      # Pretty print the node
      #
      # @param pp [PP] The pretty printer
      # @return [void]
      def pretty_print(pp)
        pp.text("KeywordNode")
        pp.nest(2) do
          pp.breakable
          pp.text("value: ")
          pp.pp(value)
        end
      end
    end
  end
end
