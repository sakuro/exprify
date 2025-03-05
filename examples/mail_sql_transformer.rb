# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__)) if $PROGRAM_NAME == __FILE__

require "date"
require "exprify"

# Example transformer that converts search expressions into SQL WHERE clauses
# This transformer generates SQL conditions suitable for email search
class MailSqlTransformer < Exprify::Transformers::Base
  # Visit a keyword node and transform it into a SQL LIKE condition
  #
  # @param node [Object] The keyword node to visit
  # @return [Array<String, Array>] SQL condition and parameters
  def visit_keyword(node)
    ["(subject LIKE ? OR body LIKE ?)", ["#{node.value}%", "%#{node.value}%"]]
  end

  # Visit an AND node and combine its children with SQL AND
  #
  # @param node [Object] The AND node to visit
  # @return [Array<String, Array>] SQL condition and parameters
  def visit_and(node)
    conditions = []
    params = []

    node.children.each do |child|
      sql, child_params = child.accept(self)
      conditions << sql
      params.concat(child_params)
    end

    [conditions.join(" AND "), params]
  end

  # Visit an OR node and combine its children with SQL OR
  #
  # @param node [Object] The OR node to visit
  # @return [Array<String, Array>] SQL condition and parameters
  def visit_or(node)
    conditions = []
    params = []

    node.children.each do |child|
      sql, child_params = child.accept(self)
      conditions << sql
      params.concat(child_params)
    end

    [conditions.join(" OR "), params]
  end

  # Visit a NOT node and negate its child condition
  #
  # @param node [Object] The NOT node to visit
  # @return [Array<String, Array>] SQL condition and parameters
  def visit_not(node)
    sql, params = node.expression.accept(self)
    ["NOT (#{sql})", params]
  end

  # Visit an exact phrase node and transform it into a SQL = condition
  #
  # @param node [Object] The exact phrase node to visit
  # @return [Array<String, Array>] SQL condition and parameters
  def visit_exact_phrase(node)
    ["(subject = ? OR body = ?)", [node.phrase, node.phrase]]
  end

  # Visit a group node and transform its child
  #
  # @param node [Object] The group node to visit
  # @return [Array<String, Array>] SQL condition and parameters
  def visit_group(node)
    sql, params = node.child.accept(self)
    ["(#{sql})", params]
  end

  # Visit a named argument node and transform it into a date-based SQL condition
  #
  # @param node [Object] The named argument node to visit
  # @return [Array<String, Array>] SQL condition and parameters
  def visit_named_argument(node)
    case node.name
    when "since"
      ["date >= ?", [parse_date(node.value).to_s]]
    when "until"
      ["date <= ?", [parse_date(node.value).to_s]]
    else
      raise ArgumentError, "Unknown argument: #{node.name}"
    end
  end

  # Parse a date string into a Date object
  #
  # @param value [String] The date string to parse
  # @return [Date] The parsed date
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

  # Transform the input string and print the result
  #
  # @param input [String] The input search expression
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
