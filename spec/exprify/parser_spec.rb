# frozen_string_literal: true

RSpec.describe Exprify::Parser do
  subject(:parser) { described_class.new }

  describe "#parse" do
    context "with single keyword" do
      it "creates a keyword node" do
        ast = parser.parse("ruby")
        expect(ast).to be_a(Exprify::AST::KeywordNode)
        expect(ast.value).to eq("ruby")
      end
    end

    context "with multiple keywords" do
      it "creates an AND node" do
        ast = parser.parse("ruby gem")
        expect(ast).to be_a(Exprify::AST::AndNode)
        expect(ast.children.size).to eq(2)
        expect(ast.children[0]).to be_a(Exprify::AST::KeywordNode)
        expect(ast.children[0].value).to eq("ruby")
        expect(ast.children[1]).to be_a(Exprify::AST::KeywordNode)
        expect(ast.children[1].value).to eq("gem")
      end

      it "handles multiple keywords" do
        ast = parser.parse("ruby gem rails")
        expect(ast).to be_a(Exprify::AST::AndNode)
        expect(ast.children.size).to eq(3)
        expect(ast.children.map(&:value)).to eq(%w[ruby gem rails])
      end
    end

    context "with OR operator" do
      it "creates an OR node" do
        ast = parser.parse("ruby OR gem")
        expect(ast).to be_a(Exprify::AST::OrNode)
        expect(ast.children.size).to eq(2)
        expect(ast.children[0]).to be_a(Exprify::AST::KeywordNode)
        expect(ast.children[0].value).to eq("ruby")
        expect(ast.children[1]).to be_a(Exprify::AST::KeywordNode)
        expect(ast.children[1].value).to eq("gem")
      end

      it "handles multiple OR operators" do
        ast = parser.parse("ruby OR gem OR rails")
        expect(ast).to be_a(Exprify::AST::OrNode)
        expect(ast.children.size).to eq(3)
        expect(ast.children.map(&:value)).to eq(%w[ruby gem rails])
      end
    end

    context "with NOT operator" do
      it "creates a NOT node" do
        ast = parser.parse("-deprecated")
        expect(ast).to be_a(Exprify::AST::NotNode)
        expect(ast.expression).to be_a(Exprify::AST::KeywordNode)
        expect(ast.expression.value).to eq("deprecated")
      end

      it "handles NOT with other operators" do
        ast = parser.parse("ruby -deprecated")
        expect(ast).to be_a(Exprify::AST::AndNode)
        expect(ast.children.size).to eq(2)
        expect(ast.children[0]).to be_a(Exprify::AST::KeywordNode)
        expect(ast.children[1]).to be_a(Exprify::AST::NotNode)
      end
    end

    context "with grouping" do
      it "creates a group node" do
        ast = parser.parse("(ruby)")
        expect(ast).to be_a(Exprify::AST::GroupNode)
        expect(ast.expression).to be_a(Exprify::AST::KeywordNode)
        expect(ast.expression.value).to eq("ruby")
      end

      it "handles complex grouping" do
        ast = parser.parse("(ruby OR gem) rails")
        expect(ast).to be_a(Exprify::AST::AndNode)
        expect(ast.children.size).to eq(2)
        expect(ast.children[0]).to be_a(Exprify::AST::GroupNode)
        expect(ast.children[1]).to be_a(Exprify::AST::KeywordNode)
        expect(ast.children[1].value).to eq("rails")
      end

      it "handles multiple terms in group" do
        ast = parser.parse("(ruby OR gem OR rails)")
        expect(ast).to be_a(Exprify::AST::GroupNode)
        expect(ast.expression).to be_a(Exprify::AST::OrNode)
        expect(ast.expression.children.size).to eq(3)
        expect(ast.expression.children.map(&:value)).to eq(%w[ruby gem rails])
      end
    end

    context "with exact phrase" do
      it "creates an exact phrase node" do
        ast = parser.parse('"exact phrase"')
        expect(ast).to be_a(Exprify::AST::ExactPhraseNode)
        expect(ast.phrase).to eq("exact phrase")
      end
    end

    context "with named arguments" do
      it "creates a named argument node" do
        result = parser.parse("name:value")
        expect(result).to be_a(Exprify::AST::NamedArgumentNode)
        expect(result.name).to eq("name")
        expect(result.value).to eq("value")
      end

      it "handles quoted values" do
        result = parser.parse('name:"quoted value"')
        expect(result).to be_a(Exprify::AST::NamedArgumentNode)
        expect(result.name).to eq("name")
        expect(result.value).to eq("quoted value")
      end

      it "handles values with colons" do
        result = parser.parse('name:"value:with:colons"')
        expect(result).to be_a(Exprify::AST::NamedArgumentNode)
        expect(result.name).to eq("name")
        expect(result.value).to eq("value:with:colons")
      end

      it "treats invalid format as keyword" do
        result = parser.parse(":value")
        expect(result).to be_a(Exprify::AST::KeywordNode)
        expect(result.value).to eq(":value")
      end

      it "treats empty value as keyword" do
        result = parser.parse("name:")
        expect(result).to be_a(Exprify::AST::KeywordNode)
        expect(result.value).to eq("name:")
      end

      it "handles multiple named arguments" do
        result = parser.parse("name:value tag:ruby")
        expect(result).to be_a(Exprify::AST::AndNode)
        expect(result.children.size).to eq(2)
        expect(result.children[0]).to be_a(Exprify::AST::NamedArgumentNode)
        expect(result.children[0].name).to eq("name")
        expect(result.children[0].value).to eq("value")
        expect(result.children[1]).to be_a(Exprify::AST::NamedArgumentNode)
        expect(result.children[1].name).to eq("tag")
        expect(result.children[1].value).to eq("ruby")
      end

      it "handles named arguments with quoted values and keywords" do
        result = parser.parse('name:"quoted value" tag:ruby keyword')
        expect(result).to be_a(Exprify::AST::AndNode)
        expect(result.children.size).to eq(3)
        expect(result.children[0]).to be_a(Exprify::AST::NamedArgumentNode)
        expect(result.children[0].name).to eq("name")
        expect(result.children[0].value).to eq("quoted value")
        expect(result.children[1]).to be_a(Exprify::AST::NamedArgumentNode)
        expect(result.children[1].name).to eq("tag")
        expect(result.children[1].value).to eq("ruby")
        expect(result.children[2]).to be_a(Exprify::AST::KeywordNode)
        expect(result.children[2].value).to eq("keyword")
      end

      it "handles named arguments with OR operator" do
        result = parser.parse('name:"value1" OR name:"value2"')
        expect(result).to be_a(Exprify::AST::OrNode)
        expect(result.children.size).to eq(2)
        expect(result.children[0]).to be_a(Exprify::AST::NamedArgumentNode)
        expect(result.children[0].name).to eq("name")
        expect(result.children[0].value).to eq("value1")
        expect(result.children[1]).to be_a(Exprify::AST::NamedArgumentNode)
        expect(result.children[1].name).to eq("name")
        expect(result.children[1].value).to eq("value2")
      end

      it "handles named arguments with grouping" do
        result = parser.parse('(name:"value1" OR name:"value2") tag:ruby')
        expect(result).to be_a(Exprify::AST::AndNode)
        expect(result.children.size).to eq(2)
        expect(result.children[0]).to be_a(Exprify::AST::GroupNode)
        group = result.children[0].expression
        expect(group).to be_a(Exprify::AST::OrNode)
        expect(group.children[0].name).to eq("name")
        expect(group.children[0].value).to eq("value1")
        expect(group.children[1].name).to eq("name")
        expect(group.children[1].value).to eq("value2")
        expect(result.children[1]).to be_a(Exprify::AST::NamedArgumentNode)
        expect(result.children[1].name).to eq("tag")
        expect(result.children[1].value).to eq("ruby")
      end
    end

    context "with complex expressions" do
      it "handles combination of operators" do
        ast = parser.parse('(ruby OR gem OR rails) -deprecated "exact phrase"')
        expect(ast).to be_a(Exprify::AST::AndNode)
        expect(ast.children.size).to eq(3)
        expect(ast.children[0]).to be_a(Exprify::AST::GroupNode)
        expect(ast.children[1]).to be_a(Exprify::AST::NotNode)
        expect(ast.children[2]).to be_a(Exprify::AST::ExactPhraseNode)
      end
    end

    context "with inspect output" do
      it "formats simple keyword node" do
        ast = parser.parse("ruby")
        expect(ast.inspect).to eq('#<KeywordNode value="ruby">')
      end

      it "formats AND node with multiple children" do
        ast = parser.parse("ruby gem rails")
        expect(ast.inspect).to eq('#<AndNode children=[#<KeywordNode value="ruby">, #<KeywordNode value="gem">, #<KeywordNode value="rails">]>')
      end

      it "formats OR node with multiple children" do
        ast = parser.parse("ruby OR gem OR rails")
        expect(ast.inspect).to eq('#<OrNode children=[#<KeywordNode value="ruby">, #<KeywordNode value="gem">, #<KeywordNode value="rails">]>')
      end

      it "formats NOT node" do
        ast = parser.parse("-deprecated")
        expect(ast.inspect).to eq('#<NotNode expression=#<KeywordNode value="deprecated">>')
      end

      it "formats exact phrase node" do
        ast = parser.parse('"exact phrase"')
        expect(ast.inspect).to eq('#<ExactPhraseNode phrase="exact phrase">')
      end

      it "formats complex expression" do
        ast = parser.parse("(ruby OR gem) -deprecated")
        expect(ast.inspect).to eq('#<AndNode children=[#<GroupNode expression=#<OrNode children=[#<KeywordNode value="ruby">, #<KeywordNode value="gem">]>>, #<NotNode expression=#<KeywordNode value="deprecated">>]>')
      end
    end

    context "with errors" do
      it "raises error on unmatched parentheses" do
        expect { parser.parse("(ruby") }.to raise_error(Exprify::Error)
      end

      it "raises error on unexpected tokens" do
        expect { parser.parse(")") }.to raise_error(Exprify::Error)
      end

      it "raises error on empty input" do
        expect { parser.parse("") }.to raise_error(Exprify::Error)
      end
    end
  end

  context "with additional cases" do
    it "handles grouped expressions followed by named arguments" do
      result = parser.parse("(a OR b) since:2025-1-1")
      expect(result).to be_a(Exprify::AST::AndNode)
      expect(result.children.size).to eq(2)
      expect(result.children[0]).to be_a(Exprify::AST::GroupNode)
      expect(result.children[1]).to be_a(Exprify::AST::NamedArgumentNode)
      expect(result.children[1].name).to eq("since")
      expect(result.children[1].value).to eq("2025-1-1")
    end

    it "handles grouped expressions followed by keywords" do
      result = parser.parse("(a OR b) keyword")
      expect(result).to be_a(Exprify::AST::AndNode)
      expect(result.children.size).to eq(2)
      expect(result.children[0]).to be_a(Exprify::AST::GroupNode)
      expect(result.children[1]).to be_a(Exprify::AST::KeywordNode)
      expect(result.children[1].value).to eq("keyword")
    end

    it "handles complex combinations with groups, negations and named arguments" do
      result = parser.parse("(a OR b) -c since:2025-1-1")
      expect(result).to be_a(Exprify::AST::AndNode)
      expect(result.children.size).to eq(3)
      expect(result.children[0]).to be_a(Exprify::AST::GroupNode)
      expect(result.children[1]).to be_a(Exprify::AST::NotNode)
      expect(result.children[2]).to be_a(Exprify::AST::NamedArgumentNode)
      expect(result.children[2].name).to eq("since")
      expect(result.children[2].value).to eq("2025-1-1")
    end
  end
end
