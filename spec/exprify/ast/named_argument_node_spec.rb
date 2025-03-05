# frozen_string_literal: true

RSpec.describe Exprify::AST::NamedArgumentNode do
  let(:node) { described_class.new("name", "value") }

  describe "#accept" do
    it "calls visit_named_argument on visitor" do
      visitor = double("visitor")
      expect(visitor).to receive(:visit_named_argument).with(node)
      node.accept(visitor)
    end
  end

  describe "#inspect" do
    it "includes name and value" do
      expect(node.inspect).to include("name")
      expect(node.inspect).to include("value")
    end
  end

  describe "#pretty_print" do
    it "formats node with name and value" do
      output = StringIO.new
      PP.pp(node, output)
      pp_output = output.string

      expect(pp_output).to include("NamedArgumentNode")
      expect(pp_output).to include("name")
      expect(pp_output).to include("value")
    end
  end
end
