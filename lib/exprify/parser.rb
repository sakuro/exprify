# frozen_string_literal: true

module Exprify
  # Parser for search expressions that converts input strings into AST nodes
  class Parser
    class Token
      attr_reader :type
      attr_reader :value

      def initialize(type, value)
        @type = type
        @value = value
      end
    end

    private_constant :Token

    # Regular expression for special characters in search expressions
    SPECIAL_CHARS = /[\s()"]/
    private_constant :SPECIAL_CHARS

    # List of supported operators
    OPERATORS = %w[OR].freeze
    private_constant :OPERATORS

    def initialize
      # 将来的にオプションを受け付ける予定
    end

    def parse(input)
      raise Error, "Empty input" if input.nil? || input.strip.empty?

      @tokens = tokenize(input)
      @position = 0
      parse_expression
    end

    private def tokenize(input)
      tokens = []
      pos = 0

      while pos < input.length
        char = input[pos]

        case char
        when " ", "\t", "\n", "\r"
          pos += 1
        when "("
          tokens << Token.new(:lparen, char)
          pos += 1
        when ")"
          tokens << Token.new(:rparen, char)
          pos += 1
        when "-"
          if pos.zero? || input[pos - 1] =~ /\s/
            tokens << Token.new(:not, char)
            pos += 1
          else
            # ハイフンを含む単語として処理
            word, end_pos = scan_to_boundary(input, pos)
            tokens << Token.new(:keyword, word)
            pos = end_pos
          end
        when '"'
          phrase, end_pos = scan_phrase(input, pos + 1)
          tokens << Token.new(:phrase, phrase)
          pos = end_pos
        else
          word, end_pos = scan_to_boundary(input, pos)
          token = process_word(word)
          tokens << token
          pos = end_pos
        end
      end

      tokens << Token.new(:eof, nil)
      tokens
    end

    private def scan_to_boundary(input, start)
      pos = start
      in_quotes = false

      while pos < input.length
        char = input[pos]

        if char == '"'
          in_quotes = !in_quotes
        elsif !in_quotes
          # 引用符の外側では特殊文字をチェック
          break if char =~ /\s/
          break if char =~ SPECIAL_CHARS && char != ":" && char != '"'
        end

        pos += 1
      end

      [input[start...pos], pos]
    end

    private def scan_phrase(input, start)
      pos = start
      pos += 1 while pos < input.length && input[pos] != '"'
      raise Error, "Unterminated phrase" if pos >= input.length

      [input[start...pos], pos + 1]
    end

    private def process_word(word)
      return Token.new(:operator, word) if OPERATORS.include?(word)
      return Token.new(:keyword, word) unless word.include?(":")

      # 最初のコロンの位置を見つける
      colon_pos = word.index(":")
      name = word[0...colon_pos]
      value = word[colon_pos + 1..]

      # 名前が空の場合はキーワードとして扱う
      return Token.new(:keyword, word) if name.empty?

      # 値が引用符で囲まれている場合は引用符を除去
      value = value[1..-2] if value.start_with?('"') && value.end_with?('"') && value.length >= 2

      # 値が空の場合はキーワードとして扱う
      return Token.new(:keyword, word) if value.empty?

      Token.new(:named_arg, [name, value])
    end

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

    private def current_token
      @tokens[@position]
    end

    private def consume_token
      @position += 1
    end

    private def expect(type)
      token = current_token
      raise Error, "Expected #{type}, got #{token.type}" if token.type != type

      consume_token
    end
  end
end
