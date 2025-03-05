# frozen_string_literal: true

require "pp"

module Exprify
  # Abstract Syntax Tree nodes for representing search expressions
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

    # Node representing an AND operation
    class AndNode < Node
      # @return [Array<Node>] The child nodes
      attr_reader :children

      # Initialize a new AND node
      #
      # @param children [Array<Node>] The child nodes
      # @return [AndNode] A new AND node
      def initialize(*children)
        super()
        @children = children
      end

      # Accept a visitor
      #
      # @param visitor [Object] The visitor object
      # @return [Object] The result of the visit
      def accept(visitor)
        visitor.visit_and(self)
      end

      # Return a string representation of the node
      #
      # @return [String] The string representation
      def inspect
        "#<AndNode children=[#{children.map(&:inspect).join(", ")}]>"
      end

      # Pretty print the node
      #
      # @param pp [PP] The pretty printer
      # @return [void]
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

    # Node representing an OR operation
    class OrNode < Node
      # @return [Array<Node>] The child nodes
      attr_reader :children

      # Initialize a new OR node
      #
      # @param children [Array<Node>] The child nodes
      # @return [OrNode] A new OR node
      def initialize(*children)
        super()
        @children = children
      end

      # Accept a visitor
      #
      # @param visitor [Object] The visitor object
      # @return [Object] The result of the visit
      def accept(visitor)
        visitor.visit_or(self)
      end

      # Return a string representation of the node
      #
      # @return [String] The string representation
      def inspect
        "#<OrNode children=[#{children.map(&:inspect).join(", ")}]>"
      end

      # Pretty print the node
      #
      # @param pp [PP] The pretty printer
      # @return [void]
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

    # Node representing a NOT operation
    class NotNode < Node
      # @return [Node] The expression to negate
      attr_reader :expression

      # Initialize a new NOT node
      #
      # @param expression [Node] The expression to negate
      # @return [NotNode] A new NOT node
      def initialize(expression)
        super()
        @expression = expression
      end

      # Accept a visitor
      #
      # @param visitor [Object] The visitor object
      # @return [Object] The result of the visit
      def accept(visitor)
        visitor.visit_not(self)
      end

      # Return a string representation of the node
      #
      # @return [String] The string representation
      def inspect
        "#<NotNode expression=#{expression.inspect}>"
      end

      # Pretty print the node
      #
      # @param pp [PP] The pretty printer
      # @return [void]
      def pretty_print(pp)
        pp.text("NotNode")
        pp.nest(2) do
          pp.breakable
          pp.text("expression: ")
          expression.pretty_print(pp)
        end
      end
    end

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

      # Accept a visitor
      #
      # @param visitor [Object] The visitor object
      # @return [Object] The result of the visit
      def accept(visitor)
        visitor.visit_keyword(self)
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

    # Node representing a group (parenthesized expression)
    class GroupNode < Node
      # @return [Node] The grouped expression
      attr_reader :expression

      # Initialize a new group node
      #
      # @param expression [Node] The grouped expression
      # @return [GroupNode] A new group node
      def initialize(expression)
        super()
        @expression = expression
      end

      # Accept a visitor
      #
      # @param visitor [Object] The visitor object
      # @return [Object] The result of the visit
      def accept(visitor)
        visitor.visit_group(self)
      end

      # Return a string representation of the node
      #
      # @return [String] The string representation
      def inspect
        "#<GroupNode expression=#{expression.inspect}>"
      end

      # Pretty print the node
      #
      # @param pp [PP] The pretty printer
      # @return [void]
      def pretty_print(pp)
        pp.text("GroupNode")
        pp.nest(2) do
          pp.breakable
          pp.text("expression: ")
          expression.pretty_print(pp)
        end
      end
    end

    # Node representing an exact phrase to match
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
