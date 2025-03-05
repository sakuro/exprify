# frozen_string_literal: true

RSpec.describe Exprify::AST::KeywordNode do
  let(:node) { described_class.new("test") }

  describe "#accept" do
    it "calls visit_keyword on visitor" do
      visitor = double("visitor")
      expect(visitor).to receive(:visit_keyword).with(node)
      node.accept(visitor)
    end
  end

  describe "#inspect" do
    it "includes value" do
      expect(node.inspect).to include("test")
    end
  end

  describe "#pretty_print" do
    it "formats node with value" do
      output = StringIO.new
      PP.pp(node, output)
      pp_output = output.string

      expect(pp_output).to include("KeywordNode")
      expect(pp_output).to include("value")
      expect(pp_output).to include("test")
    end
  end
end
