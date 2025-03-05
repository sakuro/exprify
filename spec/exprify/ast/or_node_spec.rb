# frozen_string_literal: true

require_relative "../../../lib/exprify/transformers/base"

RSpec.describe Exprify::AST::OrNode do
  let(:first_keyword) { Exprify::AST::KeywordNode.new("test1") }
  let(:second_keyword) { Exprify::AST::KeywordNode.new("test2") }
  let(:node) { Exprify::AST::OrNode.new(first_keyword, second_keyword) }

  describe "#accept" do
    it "calls transform_or on transformer" do
      transformer = instance_double(Exprify::Transformers::Base)
      allow(transformer).to receive(:transform_or).with(node)
      node.accept(transformer)
      expect(transformer).to have_received(:transform_or).with(node)
    end
  end

  describe "#inspect" do
    it "includes first keyword" do
      expect(node.inspect).to include("test1")
    end

    it "includes second keyword" do
      expect(node.inspect).to include("test2")
    end
  end

  describe "#pretty_print" do
    let(:output) { StringIO.new }
    let(:pp_output) do
      PP.pp(node, output)
      output.string
    end

    it "includes node type" do
      expect(pp_output).to include("OrNode")
    end

    it "includes children section" do
      expect(pp_output).to include("children")
    end

    it "includes first keyword" do
      expect(pp_output).to include("test1")
    end

    it "includes second keyword" do
      expect(pp_output).to include("test2")
    end
  end
end
