# frozen_string_literal: true

RSpec.describe Exprify::AST::Node do
  describe "#accept" do
    it "raises NotImplementedError" do
      node = Exprify::AST::Node.new
      expect { node.accept(nil) }.to raise_error(NotImplementedError)
    end
  end

  describe "#inspect" do
    it "returns class name" do
      node = Exprify::AST::Node.new
      expect(node.inspect).to eq("#<Node>")
    end
  end

  describe "#pretty_print" do
    it "outputs class name" do
      node = Exprify::AST::Node.new
      output = StringIO.new
      PP.pp(node, output)
      expect(output.string).to include("Node")
    end
  end
end
