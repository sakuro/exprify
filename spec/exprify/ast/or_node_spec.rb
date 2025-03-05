# frozen_string_literal: true

RSpec.describe Exprify::AST::OrNode do
  let(:child1) { Exprify::AST::KeywordNode.new("test1") }
  let(:child2) { Exprify::AST::KeywordNode.new("test2") }
  let(:node) { described_class.new(child1, child2) }

  describe "#accept" do
    it "calls visit_or on visitor" do
      visitor = double("visitor")
      expect(visitor).to receive(:visit_or).with(node)
      node.accept(visitor)
    end
  end

  describe "#inspect" do
    it "includes children" do
      expect(node.inspect).to include("test1")
      expect(node.inspect).to include("test2")
    end
  end

  describe "#pretty_print" do
    it "formats node with children" do
      output = StringIO.new
      PP.pp(node, output)
      pp_output = output.string

      expect(pp_output).to include("OrNode")
      expect(pp_output).to include("children")
      expect(pp_output).to include("test1")
      expect(pp_output).to include("test2")
    end
  end
end
