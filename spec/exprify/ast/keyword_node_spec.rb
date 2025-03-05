# frozen_string_literal: true

require_relative "../../../lib/exprify/transformers/base"

RSpec.describe Exprify::AST::KeywordNode do
  let(:node) { described_class.new("test") }

  describe "#accept" do
    it "calls visit_keyword on visitor" do
      visitor = instance_double(Exprify::Transformers::Base)
      allow(visitor).to receive(:visit_keyword).with(node)
      node.accept(visitor)
      expect(visitor).to have_received(:visit_keyword).with(node)
    end
  end

  describe "#inspect" do
    it "includes keyword" do
      expect(node.inspect).to include("test")
    end
  end

  describe "#pretty_print" do
    let(:output) { StringIO.new }
    let(:pp_output) do
      PP.pp(node, output)
      output.string
    end

    it "includes node type" do
      expect(pp_output).to include("KeywordNode")
    end

    it "includes value section" do
      expect(pp_output).to include("value")
    end

    it "includes keyword value" do
      expect(pp_output).to include("test")
    end
  end
end
