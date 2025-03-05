# frozen_string_literal: true

RSpec.describe Exprify::Parser do
  subject(:parser) { described_class.new }

  describe "#parse" do
    context "with single keyword" do
      it "creates a keyword node" do
        ast = parser.parse("ruby")
        aggregate_failures "keyword node structure" do
          expect(ast).to be_a(Exprify::AST::KeywordNode)
          expect(ast.value).to eq("ruby")
        end
      end
    end

    context "with multiple keywords" do
      it "creates an AND node" do
        ast = parser.parse("ruby gem")
        aggregate_failures "AND node structure" do
          expect(ast).to be_a(Exprify::AST::AndNode)
          expect(ast.children.size).to eq(2)
          expect(ast.children[0]).to be_a(Exprify::AST::KeywordNode)
          expect(ast.children[0].value).to eq("ruby")
          expect(ast.children[1]).to be_a(Exprify::AST::KeywordNode)
          expect(ast.children[1].value).to eq("gem")
        end
      end

      it "handles multiple keywords" do
        ast = parser.parse("ruby gem rails")
        aggregate_failures "multiple keywords structure" do
          expect(ast).to be_a(Exprify::AST::AndNode)
          expect(ast.children.size).to eq(3)
          expect(ast.children.map(&:value)).to eq(%w[ruby gem rails])
        end
      end
    end

    context "with OR operator" do
      it "creates an OR node" do
        ast = parser.parse("ruby OR gem")
        aggregate_failures "OR node structure" do
          expect(ast).to be_a(Exprify::AST::OrNode)
          expect(ast.children.size).to eq(2)
          expect(ast.children[0]).to be_a(Exprify::AST::KeywordNode)
          expect(ast.children[0].value).to eq("ruby")
          expect(ast.children[1]).to be_a(Exprify::AST::KeywordNode)
          expect(ast.children[1].value).to eq("gem")
        end
      end

      it "handles multiple OR operators" do
        ast = parser.parse("ruby OR gem OR rails")
        aggregate_failures "multiple OR operators structure" do
          expect(ast).to be_a(Exprify::AST::OrNode)
          expect(ast.children.size).to eq(3)
          expect(ast.children.map(&:value)).to eq(%w[ruby gem rails])
        end
      end
    end

    context "with NOT operator" do
      it "creates a NOT node" do
        ast = parser.parse("-deprecated")
        aggregate_failures "NOT node structure" do
          expect(ast).to be_a(Exprify::AST::NotNode)
          expect(ast.expression).to be_a(Exprify::AST::KeywordNode)
          expect(ast.expression.value).to eq("deprecated")
        end
      end

      it "handles NOT with other operators" do
        ast = parser.parse("ruby -deprecated")
        aggregate_failures "NOT with other operators structure" do
          expect(ast).to be_a(Exprify::AST::AndNode)
          expect(ast.children.size).to eq(2)
          expect(ast.children[0]).to be_a(Exprify::AST::KeywordNode)
          expect(ast.children[1]).to be_a(Exprify::AST::NotNode)
        end
      end
    end

    context "with grouping" do
      it "creates a group node" do
        ast = parser.parse("(ruby)")
        aggregate_failures "group node structure" do
          expect(ast).to be_a(Exprify::AST::GroupNode)
          expect(ast.expression).to be_a(Exprify::AST::KeywordNode)
          expect(ast.expression.value).to eq("ruby")
        end
      end

      it "handles complex grouping" do
        ast = parser.parse("(ruby OR gem) rails")
        aggregate_failures "complex grouping structure" do
          expect(ast).to be_a(Exprify::AST::AndNode)
          expect(ast.children.size).to eq(2)
          expect(ast.children[0]).to be_a(Exprify::AST::GroupNode)
          expect(ast.children[1]).to be_a(Exprify::AST::KeywordNode)
          expect(ast.children[1].value).to eq("rails")
        end
      end

      it "handles multiple terms in group" do
        ast = parser.parse("(ruby OR gem OR rails)")
        aggregate_failures "multiple terms in group structure" do
          expect(ast).to be_a(Exprify::AST::GroupNode)
          expect(ast.expression).to be_a(Exprify::AST::OrNode)
          expect(ast.expression.children.size).to eq(3)
          expect(ast.expression.children.map(&:value)).to eq(%w[ruby gem rails])
        end
      end
    end

    context "with exact phrase" do
      it "creates an exact phrase node" do
        ast = parser.parse('"exact phrase"')
        aggregate_failures "exact phrase node structure" do
          expect(ast).to be_a(Exprify::AST::ExactPhraseNode)
          expect(ast.phrase).to eq("exact phrase")
        end
      end
    end

    context "with named arguments" do
      it "creates a named argument node" do
        result = parser.parse("name:value")
        aggregate_failures "named argument node structure" do
          expect(result).to be_a(Exprify::AST::NamedArgumentNode)
          expect(result.name).to eq("name")
          expect(result.value).to eq("value")
        end
      end

      it "handles quoted values" do
        result = parser.parse('name:"quoted value"')
        aggregate_failures "quoted values structure" do
          expect(result).to be_a(Exprify::AST::NamedArgumentNode)
          expect(result.name).to eq("name")
          expect(result.value).to eq("quoted value")
        end
      end

      it "handles values with colons" do
        result = parser.parse('name:"value:with:colons"')
        aggregate_failures "values with colons structure" do
          expect(result).to be_a(Exprify::AST::NamedArgumentNode)
          expect(result.name).to eq("name")
          expect(result.value).to eq("value:with:colons")
        end
      end

      it "treats invalid format as keyword" do
        result = parser.parse(":value")
        aggregate_failures "invalid format structure" do
          expect(result).to be_a(Exprify::AST::KeywordNode)
          expect(result.value).to eq(":value")
        end
      end

      it "treats empty value as keyword" do
        result = parser.parse("name:")
        aggregate_failures "empty value structure" do
          expect(result).to be_a(Exprify::AST::KeywordNode)
          expect(result.value).to eq("name:")
        end
      end

      it "handles multiple named arguments" do
        result = parser.parse("name:value tag:ruby")
        aggregate_failures "multiple named arguments structure" do
          expect(result).to be_a(Exprify::AST::AndNode)
          expect(result.children.size).to eq(2)
          expect(result.children[0]).to be_a(Exprify::AST::NamedArgumentNode)
          expect(result.children[0].name).to eq("name")
          expect(result.children[0].value).to eq("value")
          expect(result.children[1]).to be_a(Exprify::AST::NamedArgumentNode)
          expect(result.children[1].name).to eq("tag")
          expect(result.children[1].value).to eq("ruby")
        end
      end

      it "handles named arguments with quoted values and keywords" do
        result = parser.parse('name:"quoted value" tag:ruby keyword')
        aggregate_failures "named arguments with quoted values and keywords structure" do
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
      end

      it "handles named arguments with OR operator" do
        result = parser.parse('name:"value1" OR name:"value2"')
        aggregate_failures "named arguments with OR operator structure" do
          expect(result).to be_a(Exprify::AST::OrNode)
          expect(result.children.size).to eq(2)
          expect(result.children[0]).to be_a(Exprify::AST::NamedArgumentNode)
          expect(result.children[0].name).to eq("name")
          expect(result.children[0].value).to eq("value1")
          expect(result.children[1]).to be_a(Exprify::AST::NamedArgumentNode)
          expect(result.children[1].name).to eq("name")
          expect(result.children[1].value).to eq("value2")
        end
      end

      it "handles named arguments with grouping" do
        result = parser.parse('(name:"value1" OR name:"value2") tag:ruby')
        aggregate_failures "named arguments with grouping structure" do
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
    end

    context "with complex expressions" do
      it "handles combination of operators" do
        ast = parser.parse('(ruby OR gem OR rails) -deprecated "exact phrase"')
        aggregate_failures "combination of operators structure" do
          expect(ast).to be_a(Exprify::AST::AndNode)
          expect(ast.children.size).to eq(3)
          expect(ast.children[0]).to be_a(Exprify::AST::GroupNode)
          expect(ast.children[1]).to be_a(Exprify::AST::NotNode)
          expect(ast.children[2]).to be_a(Exprify::AST::ExactPhraseNode)
        end
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
      result = parser.parse("(ruby OR gem) tag:rails")
      aggregate_failures "grouped expressions with named arguments structure" do
        expect(result).to be_a(Exprify::AST::AndNode)
        expect(result.children.size).to eq(2)
        expect(result.children[0]).to be_a(Exprify::AST::GroupNode)
        group = result.children[0].expression
        expect(group).to be_a(Exprify::AST::OrNode)
        expect(group.children[0].value).to eq("ruby")
        expect(group.children[1].value).to eq("gem")
      end
    end

    it "handles grouped expressions followed by keywords" do
      result = parser.parse("(ruby OR gem) rails")
      aggregate_failures "grouped expressions with keywords structure" do
        expect(result).to be_a(Exprify::AST::AndNode)
        expect(result.children.size).to eq(2)
        expect(result.children[0]).to be_a(Exprify::AST::GroupNode)
        expect(result.children[1]).to be_a(Exprify::AST::KeywordNode)
        expect(result.children[1].value).to eq("rails")
      end
    end

    it "handles complex combinations with groups, negations and named arguments" do
      result = parser.parse("(ruby OR gem) -deprecated tag:rails")
      aggregate_failures "complex combinations structure" do
        expect(result).to be_a(Exprify::AST::AndNode)
        expect(result.children.size).to eq(3)
        expect(result.children[0]).to be_a(Exprify::AST::GroupNode)
        expect(result.children[1]).to be_a(Exprify::AST::NotNode)
        expect(result.children[2]).to be_a(Exprify::AST::NamedArgumentNode)
        expect(result.children[2].name).to eq("tag")
        expect(result.children[2].value).to eq("rails")
      end
    end
  end
end
