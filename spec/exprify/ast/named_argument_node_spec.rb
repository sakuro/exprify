# frozen_string_literal: true

require_relative "../../../lib/exprify/transformers/base"

RSpec.describe Exprify::AST::NamedArgumentNode do
  let(:node) { described_class.new("name", "value") }

  describe "#accept" do
    it "calls transform_named_argument on transformer" do
      transformer = instance_double(Exprify::Transformers::Base)
      allow(transformer).to receive(:transform_named_argument).with(node)
      node.accept(transformer)
      expect(transformer).to have_received(:transform_named_argument).with(node)
    end
  end

  describe "#inspect" do
    it "includes argument name" do
      expect(node.inspect).to include("name")
    end

    it "includes argument value" do
      expect(node.inspect).to include("value")
    end
  end

  describe "#pretty_print" do
    let(:output) { StringIO.new }
    let(:pp_output) do
      PP.pp(node, output)
      output.string
    end

    it "includes node type" do
      expect(pp_output).to include("NamedArgumentNode")
    end

    it "includes name section" do
      expect(pp_output).to include("name")
    end

    it "includes value section" do
      expect(pp_output).to include("value")
    end
  end
end
