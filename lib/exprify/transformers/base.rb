# frozen_string_literal: true

module Exprify
  module Transformers
    # Base class for all transformers.
    #
    # This class provides a framework for implementing AST transformers.
    # Each transformer should inherit from this class and implement
    # the transform methods for each type of AST node.
    class Base
      # Transform the given AST into a specific format.
      #
      # This is the main entry point for transforming an AST.
      # It delegates to the appropriate transform method based on the node type.
      #
      # @param ast [Exprify::AST::Node] The AST node to transform.
      # @return [Object] The transformed result.
      def transform(ast)
        ast.accept(self)
      end

      # Transform an AND node and its children.
      #
      # Subclasses must implement this method to handle nodes that
      # represent AND operations between multiple terms.
      #
      # @param node [Exprify::AST::AndNode] The AND node to transform.
      # @return [Object] The transformed result.
      def transform_and(node)
        raise NotImplementedError
      end

      # Transform an OR node and its children.
      #
      # Subclasses must implement this method to handle nodes that
      # represent OR operations between multiple terms.
      #
      # @param node [Exprify::AST::OrNode] The OR node to transform.
      # @return [Object] The transformed result.
      def transform_or(node)
        raise NotImplementedError
      end

      # Transform a NOT node and its child.
      #
      # Subclasses must implement this method to handle nodes that
      # represent negation of a term.
      #
      # @param node [Exprify::AST::NotNode] The NOT node to transform.
      # @return [Object] The transformed result.
      def transform_not(node)
        raise NotImplementedError
      end

      # Transform a keyword node.
      #
      # Subclasses must implement this method to handle nodes that
      # represent simple search keywords.
      #
      # @param node [Exprify::AST::KeywordNode] The keyword node to transform.
      # @return [Object] The transformed result.
      def transform_keyword(node)
        raise NotImplementedError
      end

      # Transform a group node and its child.
      #
      # Subclasses must implement this method to handle nodes that
      # represent grouped expressions (parentheses).
      #
      # @param node [Exprify::AST::GroupNode] The group node to transform.
      # @return [Object] The transformed result.
      def transform_group(node)
        raise NotImplementedError
      end

      # Transform an exact phrase node.
      #
      # Subclasses must implement this method to handle nodes that
      # represent exact phrase matches (quoted strings).
      #
      # @param node [Exprify::AST::ExactPhraseNode] The exact phrase node to transform.
      # @return [Object] The transformed result.
      def transform_exact_phrase(node)
        raise NotImplementedError
      end

      # Transform a named argument node.
      #
      # Subclasses must implement this method to handle nodes that
      # represent key-value pairs (field:value).
      #
      # @param node [Exprify::AST::NamedArgumentNode] The named argument node to transform.
      # @return [Object] The transformed result.
      def transform_named_argument(node)
        raise NotImplementedError
      end
    end
  end
end
