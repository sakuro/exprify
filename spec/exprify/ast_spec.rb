# frozen_string_literal: true

require "pp"
require "stringio"

RSpec.describe Exprify::AST do
  let(:parser) { Exprify::Parser.new }

  describe "pretty printing" do
    it "formats AST nodes with pp" do
      ast = parser.parse('(ruby OR gem) -deprecated name:"value" "exact phrase"')

      # Capture pp output
      output = StringIO.new
      PP.pp(ast, output)
      pp_output = output.string

      # Verify all aspects of the pretty-printed output
      aggregate_failures "pretty-printed AST structure" do
        # Verify node types are preserved
        expect(pp_output).to include("AndNode")
        expect(pp_output).to include("GroupNode")
        expect(pp_output).to include("OrNode")
        expect(pp_output).to include("NotNode")
        expect(pp_output).to include("NamedArgumentNode")
        expect(pp_output).to include("ExactPhraseNode")

        # Verify values are included
        expect(pp_output).to include('"ruby"')
        expect(pp_output).to include('"gem"')
        expect(pp_output).to include('"deprecated"')
        expect(pp_output).to include('"name"')
        expect(pp_output).to include('"value"')
        expect(pp_output).to include('"exact phrase"')

        # Verify formatting includes proper indentation
        expect(pp_output).to match(/AndNode\s+children/)
        expect(pp_output).to match(/GroupNode\s+expression/)
      end
    end

    it "formats simple nodes correctly" do
      keyword_node = Exprify::AST::KeywordNode.new("test")

      output = StringIO.new
      PP.pp(keyword_node, output)
      pp_output = output.string

      aggregate_failures "pretty-printed keyword node" do
        expect(pp_output).to include("KeywordNode")
        expect(pp_output).to include('"test"')
      end
    end

    it "formats nested nodes correctly" do
      not_node = Exprify::AST::NotNode.new(
        Exprify::AST::KeywordNode.new("test")
      )

      output = StringIO.new
      PP.pp(not_node, output)
      pp_output = output.string

      aggregate_failures "pretty-printed nested node structure" do
        expect(pp_output).to include("NotNode")
        expect(pp_output).to include("KeywordNode")
        expect(pp_output).to include('"test"')
        expect(pp_output).to match(/NotNode\s+expression:\s+KeywordNode/)
      end
    end
  end
end
