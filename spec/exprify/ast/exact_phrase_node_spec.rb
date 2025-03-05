# frozen_string_literal: true

RSpec.describe Exprify::AST::ExactPhraseNode do
  let(:node) { described_class.new("test phrase") }

  describe "#accept" do
    it "calls visit_exact_phrase on visitor" do
      visitor = double("visitor")
      expect(visitor).to receive(:visit_exact_phrase).with(node)
      node.accept(visitor)
    end
  end

  describe "#inspect" do
    it "includes phrase" do
      expect(node.inspect).to include("test phrase")
    end
  end

  describe "#pretty_print" do
    it "formats node with phrase" do
      output = StringIO.new
      PP.pp(node, output)
      pp_output = output.string

      expect(pp_output).to include("ExactPhraseNode")
      expect(pp_output).to include("phrase")
      expect(pp_output).to include("test phrase")
    end
  end
end
