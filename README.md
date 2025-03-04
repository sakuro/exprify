# Exprify

:construction: **This project is under active development and not ready for production use.** :construction:

Exprify is a library for parsing search expressions into abstract syntax trees (AST) that can be transformed into various search backends.

## Features

- **Flexible Syntax Support**:
  - Space-separated AND keywords (default)
  - OR operators (`word1 OR word2`)
  - Negation (`-word`)
  - Grouping with parentheses (`(a OR b) c`)
  - Exact phrase matching with quotes (`"exact phrase"`)
  - Named arguments (`since:2024-01-01`)

- **Error Handling Modes**:
  - Strict mode: Reports syntax errors
  - Lenient mode: Preserves as much of the original input as possible

- **Extensible Backend Support**:
  - Transform AST into various search backends
  - Dependency injection support for custom backends

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

```ruby
# Basic usage
parser = Exprify::Parser.new
ast = parser.parse("ruby gem -deprecated")

# Using with SQL backend
sql_generator = Exprify::Backends::SQL.new
where_clause = sql_generator.generate(ast)

# Error handling modes
parser = Exprify::Parser.new(mode: :strict)  # raises error on invalid syntax
parser = Exprify::Parser.new(mode: :lenient) # tries to preserve invalid parts
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sakuro/exprify.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
