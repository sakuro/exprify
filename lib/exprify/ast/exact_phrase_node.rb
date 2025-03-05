# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing an exact phrase match.
    #
    # An exact phrase node represents a sequence of words that must match
    # exactly in the target text, typically enclosed in quotes in the input.
    class ExactPhraseNode < Node
      # @return [String] The exact phrase to match.
      attr_reader :phrase

      # Initialize a new exact phrase node.
      #
      # @param phrase [String] The exact phrase to match.
      # @return [ExactPhraseNode] A new instance of ExactPhraseNode.
      def initialize(phrase)
        super()
        @phrase = phrase
      end

      # Accept a transformer.
      #
      # Dispatches to the transformer's transform_exact_phrase method with self as the argument.
      #
      # @param transformer [Exprify::Transformers::Base] The transformer object that implements transform_exact_phrase.
      # @return [Object] The result of the transform operation.
      def accept(transformer)
        transformer.transform_exact_phrase(self)
      end

      # Return a string representation of the node.
      #
      # @return [String] The string representation containing the node's class name and phrase.
      def inspect
        "#<ExactPhraseNode phrase=#{phrase.inspect}>"
      end

      # Pretty print the node.
      #
      # Outputs a human-readable representation of the node and its phrase
      # using Ruby's pretty print facility.
      #
      # @param pp [PP] The pretty printer instance.
      # @return [void]
      def pretty_print(pp)
        super
        pp.nest(2) do
          pp.breakable
          pp.text("phrase: ")
          pp.pp(phrase)
        end
      end
    end
  end
end
