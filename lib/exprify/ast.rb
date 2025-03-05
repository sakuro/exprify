# frozen_string_literal: true

require_relative "ast/and_node"
require_relative "ast/exact_phrase_node"
require_relative "ast/group_node"
require_relative "ast/keyword_node"
require_relative "ast/named_argument_node"
require_relative "ast/node"
require_relative "ast/not_node"
require_relative "ast/or_node"

module Exprify
  # Abstract Syntax Tree nodes for representing search expressions.
  #
  # This module contains all the node types used to build the AST
  # after parsing a search expression.
  module AST
  end
end
