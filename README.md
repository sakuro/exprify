# Exprify

:construction: **This project is under active development and not ready for production use.** :construction:

Exprify is a library for parsing search expressions into abstract syntax trees (AST). The AST can be transformed into various formats by implementing a transformer class.

See [TODO.md](TODO.md) for planned features and improvements.

## Features

### Syntax support

- **Basic Operators**
  - Space-separated AND keywords (default): `ruby gem`
  - OR operator: `ruby OR gem`
  - Negation: `-deprecated`
  - Grouping: `(ruby OR gem) -deprecated`
  - Exact phrase matching: `"exact phrase"`
  - Named arguments: `since:2024-01-01`

### AST transformation

To use the AST, implement a transformer class by extending `Exprify::Transformers::Base`. The transformer visits each node in the AST and converts it to your desired format.

An example implementation is included:

- `MailSqlTransformer` (`examples/mail_sql_transformer.rb`) - Generates SQL conditions for filtering RFC822 messages

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'exprify'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install exprify
```

## Usage

### Basic parsing

```ruby
require 'exprify'

# Create a parser
parser = Exprify::Parser.new

# Parse a simple expression
ast = parser.parse("ruby gem -deprecated")

# Parse with grouping and operators
ast = parser.parse('(ruby OR gem) tag:"web framework"')
```

### Implementing a transformer

Create your transformer by implementing the visitor methods for each node type:

```ruby
class MyTransformer < Exprify::Transformers::Base
  def visit_keyword(node)
    # Transform keyword node
  end

  def visit_and(node)
    # Transform AND node
  end

  def visit_or(node)
    # Transform OR node
  end

  def visit_not(node)
    # Transform NOT node
  end

  def visit_group(node)
    # Transform group node
  end

  def visit_exact_phrase(node)
    # Transform exact phrase node
  end

  def visit_named_argument(node)
    # Transform named argument node
  end
end

# Using your transformer
transformer = MyTransformer.new
result = transformer.transform(ast)
```

See the included transformer for an implementation example:
- `MailSqlTransformer` (`examples/mail_sql_transformer.rb`) - SQL condition generation for RFC822 message filtering

## Design

### AST structure

The parser generates an AST with the following node types:

- `KeywordNode`: Simple search terms
- `AndNode`: Space-separated terms or explicit AND
- `OrNode`: Terms joined with OR
- `NotNode`: Negated terms
- `GroupNode`: Parenthesized expressions
- `ExactPhraseNode`: Quoted phrases
- `NamedArgumentNode`: Key-value pairs

### Transformation process

1. Input string is tokenized
2. Tokens are parsed into an AST
3. AST is visited by a transformer
4. Transformer generates the desired output format

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sakuro/exprify.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
