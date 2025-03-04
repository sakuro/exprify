# frozen_string_literal: true

require "pp"

module Exprify
  # Abstract Syntax Tree nodes for representing search expressions
  module AST
    class Node
      def accept(visitor)
        raise NotImplementedError
      end

      def inspect
        "#<#{self.class.name.split("::").last}>"
      end

      def pretty_print(pp)
        pp.text(self.class.name.split("::").last)
      end
    end

    class AndNode < Node
      attr_reader :children

      def initialize(*children)
        super()
        @children = children
      end

      def accept(visitor)
        visitor.visit_and(self)
      end

      def inspect
        "#<AndNode children=[#{children.map(&:inspect).join(", ")}]>"
      end

      def pretty_print(pp)
        pp.text("AndNode")
        pp.nest(2) do
          pp.breakable
          pp.text("children: [")
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

    class OrNode < Node
      attr_reader :children

      def initialize(*children)
        super()
        @children = children
      end

      def accept(visitor)
        visitor.visit_or(self)
      end

      def inspect
        "#<OrNode children=[#{children.map(&:inspect).join(", ")}]>"
      end

      def pretty_print(pp)
        pp.text("OrNode")
        pp.nest(2) do
          pp.breakable
          pp.text("children: [")
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

    class NotNode < Node
      attr_reader :expression

      def initialize(expression)
        super()
        @expression = expression
      end

      def accept(visitor)
        visitor.visit_not(self)
      end

      def inspect
        "#<NotNode expression=#{expression.inspect}>"
      end

      def pretty_print(pp)
        pp.text("NotNode")
        pp.nest(2) do
          pp.breakable
          pp.text("expression: ")
          expression.pretty_print(pp)
        end
      end
    end

    class KeywordNode < Node
      attr_reader :value

      def initialize(value)
        super()
        @value = value
      end

      def accept(visitor)
        visitor.visit_keyword(self)
      end

      def inspect
        "#<KeywordNode value=#{value.inspect}>"
      end

      def pretty_print(pp)
        pp.text("KeywordNode")
        pp.nest(2) do
          pp.breakable
          pp.text("value: ")
          pp.pp(value)
        end
      end
    end

    class NamedArgumentNode < Node
      attr_reader :name
      attr_reader :value

      def initialize(name, value)
        super()
        @name = name
        @value = value
      end

      def accept(visitor)
        visitor.visit_named_argument(self)
      end

      def inspect
        "#<NamedArgumentNode name=#{name.inspect} value=#{value.inspect}>"
      end

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

    class GroupNode < Node
      attr_reader :expression

      def initialize(expression)
        super()
        @expression = expression
      end

      def accept(visitor)
        visitor.visit_group(self)
      end

      def inspect
        "#<GroupNode expression=#{expression.inspect}>"
      end

      def pretty_print(pp)
        pp.text("GroupNode")
        pp.nest(2) do
          pp.breakable
          pp.text("expression: ")
          expression.pretty_print(pp)
        end
      end
    end

    class ExactPhraseNode < Node
      attr_reader :phrase

      def initialize(phrase)
        super()
        @phrase = phrase
      end

      def accept(visitor)
        visitor.visit_exact_phrase(self)
      end

      def inspect
        "#<ExactPhraseNode phrase=#{phrase.inspect}>"
      end

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
