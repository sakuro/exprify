# frozen_string_literal: true

module Exprify
  # Transformers for converting AST nodes into various backend representations
  module Transformers
    class Base
      def transform(ast)
        ast.accept(self)
      end

      def visit_and(node)
        raise NotImplementedError
      end

      def visit_or(node)
        raise NotImplementedError
      end

      def visit_not(node)
        raise NotImplementedError
      end

      def visit_keyword(node)
        raise NotImplementedError
      end

      def visit_named_argument(node)
        raise NotImplementedError
      end

      def visit_group(node)
        raise NotImplementedError
      end

      def visit_exact_phrase(node)
        raise NotImplementedError
      end
    end
  end
end
