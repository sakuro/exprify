# frozen_string_literal: true

require_relative "node"

module Exprify
  module AST
    # Node representing an exact phrase
    class ExactPhraseNode < Node
      # @return [String] The exact phrase
      attr_reader :phrase

      # Initialize a new exact phrase node
      #
      # @param phrase [String] The exact phrase
      # @return [ExactPhraseNode] A new exact phrase node
      def initialize(phrase)
        super()
        @phrase = phrase
      end

      # Accept a visitor
      #
      # @param visitor [Object] The visitor object
      # @return [Object] The result of the visit
      def accept(visitor)
        visitor.visit_exact_phrase(self)
      end

      # Return a string representation of the node
      #
      # @return [String] The string representation
      def inspect
        "#<ExactPhraseNode phrase=#{phrase.inspect}>"
      end

      # Pretty print the node
      #
      # @param pp [PP] The pretty printer
      # @return [void]
      def pretty_print(pp)
        pp.text("ExactPhraseNode")
        pp.nest(2) do
          pp.breakable
          pp.text("phrase: ")
          pp.pp(phrase)
        end
      end
    end
  end
end
