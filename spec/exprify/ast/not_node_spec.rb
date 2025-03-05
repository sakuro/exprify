# frozen_string_literal: true

RSpec.describe Exprify::AST::NotNode do
  let(:expression) { Exprify::AST::KeywordNode.new("test") }
  let(:node) { described_class.new(expression) }

  describe "#accept" do
    it "calls visit_not on visitor" do
      visitor = double("visitor")
      expect(visitor).to receive(:visit_not).with(node)
      node.accept(visitor)
    end
  end

  describe "#inspect" do
    it "includes expression" do
      expect(node.inspect).to include("test")
    end
  end

  describe "#pretty_print" do
    it "formats node with expression" do
      output = StringIO.new
      PP.pp(node, output)
      pp_output = output.string

      expect(pp_output).to include("NotNode")
      expect(pp_output).to include("expression")
      expect(pp_output).to include("test")
    end
  end
end
