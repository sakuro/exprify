# frozen_string_literal: true

require_relative "../../../lib/exprify/transformers/base"

RSpec.describe Exprify::AST::KeywordNode do
  let(:node) { described_class.new("test") }

  describe "#accept" do
    it "calls transform_keyword on transformer" do
      transformer = instance_double(Exprify::Transformers::Base)
      allow(transformer).to receive(:transform_keyword).with(node)
      node.accept(transformer)
      expect(transformer).to have_received(:transform_keyword).with(node)
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
