# frozen_string_literal: true

module Exprify
  module Transformers
    # Base class for all transformers
    # Provides default implementations for AST node visitors
    class Base
      # Transform the given AST into a specific format
      #
      # @param ast [Object] The AST node to transform
      # @return [Object] The transformed result
      def transform(ast)
        ast.accept(self)
      end

      # Visit an AND node and transform its children
      #
      # @param node [Object] The AND node to visit
      # @return [Object] The transformed result
      def visit_and(node)
        raise NotImplementedError
      end

      # Visit an OR node and transform its children
      #
      # @param node [Object] The OR node to visit
      # @return [Object] The transformed result
      def visit_or(node)
        raise NotImplementedError
      end

      # Visit a NOT node and transform its child
      #
      # @param node [Object] The NOT node to visit
      # @return [Object] The transformed result
      def visit_not(node)
        raise NotImplementedError
      end

      # Visit a keyword node and transform it
      #
      # @param node [Object] The keyword node to visit
      # @return [Object] The transformed result
      def visit_keyword(node)
        raise NotImplementedError
      end

      # Visit a group node and transform its child
      #
      # @param node [Object] The group node to visit
      # @return [Object] The transformed result
      def visit_group(node)
        raise NotImplementedError
      end

      # Visit an exact phrase node and transform it
      #
      # @param node [Object] The exact phrase node to visit
      # @return [Object] The transformed result
      def visit_exact_phrase(node)
        raise NotImplementedError
      end

      # Visit a named argument node and transform it
      #
      # @param node [Object] The named argument node to visit
      # @return [Object] The transformed result
      def visit_named_argument(node)
        raise NotImplementedError
      end
    end
  end
end
