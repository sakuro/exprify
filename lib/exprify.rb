# frozen_string_literal: true

require_relative "exprify/ast"
require_relative "exprify/parser"
require_relative "exprify/transformers"
require_relative "exprify/version"

# Main module for the Exprify library.
#
# Provides functionality for parsing and transforming search expressions.
module Exprify
  # Base error class for all Exprify-specific errors.
  class Error < StandardError; end
  # Your code goes here...
end
