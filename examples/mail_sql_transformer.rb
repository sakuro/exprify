# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__)) if $PROGRAM_NAME == __FILE__

require "date"
require "exprify"

# Example transformer that converts search expressions into SQL WHERE clauses.
#
# This transformer generates SQL conditions suitable for email search by
# converting AST nodes into SQL conditions that match against email fields
# like subject and body.
class MailSqlTransformer < Exprify::Transformers::Base
  # Transform a keyword node into a SQL LIKE condition.
  #
  # Generates conditions that match the keyword anywhere in the subject
  # or body.
  #
  # @param node [Exprify::AST::KeywordNode] The keyword node to transform.
  # @return [Array<String, Array<String>>] SQL condition and parameters.
  def transform_keyword(node)
    ["(subject LIKE ? OR body LIKE ?)", ["%#{node.value}%", "%#{node.value}%"]]
  end

  # Transform an AND node and combine its children with SQL AND.
  #
  # Combines multiple conditions with AND to match all terms
  # in the search expression.
  #
  # @param node [Exprify::AST::AndNode] The AND node to transform.
  # @return [Array<String, Array<String>>] SQL condition and parameters.
  def transform_and(node)
    conditions = []
    params = []

    node.children.each do |child|
      sql, child_params = child.accept(self)
      conditions << sql
      params.concat(child_params)
    end

    [conditions.join(" AND "), params]
  end

  # Transform an OR node and combine its children with SQL OR.
  #
  # Combines multiple conditions with OR to match any of the terms
  # in the search expression.
  #
  # @param node [Exprify::AST::OrNode] The OR node to transform.
  # @return [Array<String, Array<String>>] SQL condition and parameters.
  def transform_or(node)
    conditions = []
    params = []

    node.children.each do |child|
      sql, child_params = child.accept(self)
      conditions << sql
      params.concat(child_params)
    end

    [conditions.join(" OR "), params]
  end

  # Transform a NOT node and negate its child condition.
  #
  # Wraps the child condition in a NOT clause to exclude matches
  # from the search results.
  #
  # @param node [Exprify::AST::NotNode] The NOT node to transform.
  # @return [Array<String, Array<String>>] SQL condition and parameters.
  def transform_not(node)
    sql, params = node.expression.accept(self)
    ["NOT (#{sql})", params]
  end

  # Transform an exact phrase node into a SQL = condition.
  #
  # Generates conditions that require an exact match of the phrase
  # in either the subject or body.
  #
  # @param node [Exprify::AST::ExactPhraseNode] The exact phrase node to transform.
  # @return [Array<String, Array<String>>] SQL condition and parameters.
  def transform_exact_phrase(node)
    ["(subject = ? OR body = ?)", [node.phrase, node.phrase]]
  end

  # Transform a group node and its expression.
  #
  # Wraps the expression's condition in parentheses to maintain proper
  # operator precedence.
  #
  # @param node [Exprify::AST::GroupNode] The group node to transform.
  # @return [Array<String, Array<String>>] SQL condition and parameters.
  def transform_group(node)
    sql, params = node.expression.accept(self)
    ["(#{sql})", params]
  end

  # Transform a named argument node into a date-based SQL condition.
  #
  # Handles 'since' and 'until' arguments by converting them into
  # date comparison conditions. Supports both explicit dates and
  # relative terms like 'today'.
  #
  # @param node [Exprify::AST::NamedArgumentNode] The named argument node to transform.
  # @return [Array<String, Array<String>>] SQL condition and parameters.
  def transform_named_argument(node)
    case node.name
    when "since"
      ["date >= ?", [parse_date(node.value).to_s]]
    when "until"
      ["date <= ?", [parse_date(node.value).to_s]]
    else
      raise ArgumentError, "Unknown argument: #{node.name}"
    end
  end

  # Parse a date string into a Date object.
  #
  # Supports both standard date formats and special keywords
  # like 'today', 'tomorrow', and 'yesterday'.
  #
  # @param value [String] The date string to parse.
  # @return [Date] The parsed date.
  private def parse_date(value)
    case value.downcase
    when "today"
      Date.today
    when "tomorrow"
      Date.today + 1
    when "yesterday"
      Date.today - 1
    else
      Date.parse(value)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require "pp"

  # Transform the input string and print the result.
  #
  # Demonstrates the transformer by parsing and transforming
  # various search expressions into SQL conditions.
  #
  # @param input [String] The input search expression.
  # @return [void]
  def transform_and_print(input)
    parser = Exprify::Parser.new
    transformer = MailSqlTransformer.new
    where_clause, params = transformer.transform(parser.parse(input))

    puts "\nInput: #{input}"
    puts "WHERE: #{where_clause}"
    puts "Params: #{params.inspect}"
  end

  # Simple keyword search
  transform_and_print("ruby")

  # AND expression
  transform_and_print("ruby gem")

  # OR expression
  transform_and_print("ruby OR gem")

  # NOT expression
  transform_and_print("-ruby")

  # Exact phrase
  transform_and_print('"ruby gem"')

  # Date arguments
  transform_and_print('since:"Mar 5 2025"')
  transform_and_print("until:2024-12-31")
  transform_and_print('since:"today"')

  # Complex expression
  transform_and_print('ruby gem -deprecated "exact phrase" since:2024-01-01')
end
