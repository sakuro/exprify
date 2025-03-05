# frozen_string_literal: true

require_relative "../../../lib/exprify/transformers/base"

RSpec.describe Exprify::AST::GroupNode do
  let(:keyword) { Exprify::AST::KeywordNode.new("test") }
  let(:node) { Exprify::AST::GroupNode.new(keyword) }

  describe "#accept" do
    it "calls transform_group on transformer" do
      transformer = instance_double(Exprify::Transformers::Base)
      allow(transformer).to receive(:transform_group).with(node)
      node.accept(transformer)
      expect(transformer).to have_received(:transform_group).with(node)
    end
  end

  describe "#inspect" do
    it "includes expression" do
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
      expect(pp_output).to include("GroupNode")
    end

    it "includes expression section" do
      expect(pp_output).to include("expression")
    end

    it "includes expression value" do
      expect(pp_output).to include("test")
    end
  end
end
