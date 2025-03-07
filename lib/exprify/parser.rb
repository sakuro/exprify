# frozen_string_literal: true

module Exprify
  # Parser for search expressions that converts input strings into AST nodes.
  #
  # This class is responsible for tokenizing input strings and building
  # an Abstract Syntax Tree (AST) that represents the search expression.
  class Parser
    Token = Data.define(:type, :value)
    private_constant :Token

    # Regular expression for special characters in search expressions.
    #
    # Used to identify word boundaries and special tokens in the input.
    SPECIAL_CHARS = /[\s()"]/
    private_constant :SPECIAL_CHARS

    # List of supported operators.
    #
    # Currently only supports the OR operator for combining expressions.
    OPERATORS = %w[OR].freeze
    private_constant :OPERATORS

    # Initialize a new parser.
    #
    # @return [Parser] A new parser instance.
    def initialize
      # noop
    end

    # Parse the input string into an AST.
    #
    # @param input [String] The input search expression.
    # @return [AST::Node] The root node of the AST.
    # @raise [Error] If the input is invalid.
    def parse(input)
      raise Error, "Empty input" if input.nil? || input.strip.empty?

      @tokens = tokenize(input)
      @position = 0
      parse_expression
    end

    # Convert input string into a sequence of tokens.
    #
    # @param input [String] The input search expression.
    # @return [Array<Token>] The sequence of tokens.
    private def tokenize(input)
      tokens = []
      pos = 0

      while pos < input.length
        char = input[pos]

        case char
        when " ", "\t", "\n", "\r"
          pos += 1
        when "("
          tokens << Token.new(type: :lparen, value: char)
          pos += 1
        when ")"
          tokens << Token.new(type: :rparen, value: char)
          pos += 1
        when "-"
          if pos.zero? || input[pos - 1] =~ /\s/
            tokens << Token.new(type: :not, value: char)
            pos += 1
          else
            # Treat as a word containing a hyphen
            word, end_pos = scan_to_boundary(input, pos)
            tokens << Token.new(type: :keyword, value: word)
            pos = end_pos
          end
        when '"'
          phrase, end_pos = scan_phrase(input, pos + 1)
          tokens << Token.new(type: :phrase, value: phrase)
          pos = end_pos
        else
          word, end_pos = scan_to_boundary(input, pos)
          token = process_word(word)
          tokens << token
          pos = end_pos
        end
      end

      tokens << Token.new(type: :eof, value: nil)
      tokens
    end

    # Scan input until a boundary character is found
    #
    # @param input [String] The input search expression
    # @param start [Integer] The starting position
    # @return [Array<String, Integer>] The scanned word and the ending position
    private def scan_to_boundary(input, start)
      pos = start
      in_quotes = false

      while pos < input.length
        char = input[pos]

        if char == '"'
          in_quotes = !in_quotes
        elsif !in_quotes
          # Check for special characters outside quotes
          break if char =~ /\s/
          break if char =~ SPECIAL_CHARS && char != ":" && char != '"'
        end

        pos += 1
      end

      [input[start...pos], pos]
    end

    # Scan a quoted phrase
    #
    # @param input [String] The input search expression
    # @param start [Integer] The starting position (after the opening quote)
    # @return [Array<String, Integer>] The phrase and the ending position
    # @raise [Error] If the phrase is not properly terminated
    private def scan_phrase(input, start)
      pos = start
      pos += 1 while pos < input.length && input[pos] != '"'
      raise Error, "Unterminated phrase" if pos >= input.length

      [input[start...pos], pos + 1]
    end

    # Process a word into a token
    #
    # @param word [String] The word to process
    # @return [Token] The processed token
    private def process_word(word)
      return Token.new(type: :operator, value: word) if OPERATORS.include?(word)
      return Token.new(type: :keyword, value: word) unless word.include?(":")

      # Find the position of the first colon
      colon_pos = word.index(":")
      name = word[0...colon_pos]
      value = word[colon_pos + 1..]

      # If name is empty, treat as a keyword
      return Token.new(type: :keyword, value: word) if name.empty?

      # If value is quoted, remove quotes
      value = value[1..-2] if value.start_with?('"') && value.end_with?('"')

      # If value is empty, treat as a keyword
      return Token.new(type: :keyword, value: word) if value.empty?

      Token.new(type: :named_arg, value: [name, value])
    end

    # Parse an expression (sequence of terms joined by OR)
    #
    # @return [AST::Node] The root node of the expression
    # @raise [Error] If the expression is invalid
    private def parse_expression
      terms = [parse_term]
      raise Error, "No valid expression found" if terms.first.nil?

      while current_token&.type == :operator && current_token.value == "OR"
        consume_token
        term = parse_term
        raise Error, "Expected expression after OR" if term.nil?

        terms << term
      end

      return terms.first if terms.size == 1

      AST::OrNode.new(*terms)
    end

    # Parse a term (sequence of factors)
    #
    # @return [AST::Node] The root node of the term
    # @raise [Error] If the term is invalid
    private def parse_term
      nodes = []

      while (token = current_token)
        case token.type
        when :eof, :rparen, :operator
          break
        when :not
          consume_token
          nodes << AST::NotNode.new(parse_factor)
        else
          nodes << parse_factor
        end
      end

      return nodes.first if nodes.size == 1
      raise Error, "No valid expression found" if nodes.empty?

      AST::AndNode.new(*nodes)
    end

    # Parse a factor (keyword, phrase, named argument, or group)
    #
    # @return [AST::Node] The root node of the factor
    # @raise [Error] If the factor is invalid
    private def parse_factor
      token = current_token
      case token.type
      when :keyword
        consume_token
        AST::KeywordNode.new(token.value)
      when :phrase
        consume_token
        AST::ExactPhraseNode.new(token.value)
      when :named_arg
        consume_token
        AST::NamedArgumentNode.new(token.value[0], token.value[1])
      when :lparen
        consume_token
        expr = parse_expression
        expect(:rparen)
        AST::GroupNode.new(expr)
      when :rparen
        raise Error, "Unexpected closing parenthesis"
      when :eof
        raise Error, "Unexpected end of input"
      else
        raise Error, "Unexpected token: #{token.type}"
      end
    end

    # Get the current token
    #
    # @return [Token, nil] The current token or nil if at end of input
    private def current_token
      @tokens[@position]
    end

    # Move to the next token
    #
    # @return [void]
    private def consume_token
      @position += 1
    end

    # Expect a token of a specific type
    #
    # @param type [Symbol] The expected token type
    # @return [void]
    # @raise [Error] If the current token is not of the expected type
    private def expect(type)
      token = current_token
      raise Error, "Expected #{type}, got #{token.type}" if token.type != type

      consume_token
    end
  end
end
