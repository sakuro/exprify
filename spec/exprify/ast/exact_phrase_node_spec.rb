# frozen_string_literal: true

require_relative "../../../lib/exprify/transformers/base"

RSpec.describe Exprify::AST::ExactPhraseNode do
  let(:node) { described_class.new("test phrase") }

  describe "#accept" do
    it "calls visit_exact_phrase on visitor" do
      visitor = instance_double(Exprify::Transformers::Base)
      allow(visitor).to receive(:visit_exact_phrase).with(node)
      node.accept(visitor)
      expect(visitor).to have_received(:visit_exact_phrase).with(node)
    end
  end

  describe "#inspect" do
    it "includes phrase" do
      expect(node.inspect).to include("test phrase")
    end
  end

  describe "#pretty_print" do
    let(:output) { StringIO.new }
    let(:pp_output) do
      PP.pp(node, output)
      output.string
    end

    it "includes node type" do
      expect(pp_output).to include("ExactPhraseNode")
    end

    it "includes phrase section" do
      expect(pp_output).to include("phrase")
    end

    it "includes phrase value" do
      expect(pp_output).to include("test phrase")
    end
  end
end
