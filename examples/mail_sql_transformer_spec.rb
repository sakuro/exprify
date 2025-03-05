# frozen_string_literal: true

require_relative "mail_sql_transformer"

RSpec.describe MailSqlTransformer do
  subject(:transformer) { described_class.new }

  let(:parser) { Exprify::Parser.new }

  def transform(input)
    transformer.transform(parser.parse(input))
  end

  it "transforms a single keyword" do
    expect(transform("ruby")).to eq ["(subject LIKE ? OR body LIKE ?)", ["ruby%", "%ruby%"]]
  end

  it "transforms AND expression" do
    expect(transform("ruby gem")).to eq [
      "(subject LIKE ? OR body LIKE ?) AND (subject LIKE ? OR body LIKE ?)",
      ["ruby%", "%ruby%", "gem%", "%gem%"]
    ]
  end

  it "transforms OR expression" do
    expect(transform("ruby OR gem")).to eq [
      "(subject LIKE ? OR body LIKE ?) OR (subject LIKE ? OR body LIKE ?)",
      ["ruby%", "%ruby%", "gem%", "%gem%"]
    ]
  end

  it "transforms NOT expression" do
    expect(transform("-ruby")).to eq [
      "NOT ((subject LIKE ? OR body LIKE ?))",
      ["ruby%", "%ruby%"]
    ]
  end

  it "transforms exact phrase" do
    expect(transform('"ruby gem"')).to eq [
      "(subject = ? OR body = ?)",
      ["ruby gem", "ruby gem"]
    ]
  end

  describe "date arguments" do
    it "transforms ISO 8601 date" do
      expect(transform("since:2024-01-01")).to eq ["date >= ?", ["2024-01-01"]]
      expect(transform("until:2024-12-31")).to eq ["date <= ?", ["2024-12-31"]]
    end

    it "transforms month name date format" do
      expect(transform('since:"Mar 5 2025"')).to eq ["date >= ?", ["2025-03-05"]]
      expect(transform('until:"Dec 31 2025"')).to eq ["date <= ?", ["2025-12-31"]]
    end

    it "transforms relative dates" do
      expect(transform('since:"today"')).to eq ["date >= ?", [Date.today.to_s]]
      expect(transform('until:"tomorrow"')).to eq ["date <= ?", [(Date.today + 1).to_s]]
    end
  end

  it "transforms complex expression" do
    expect(transform('ruby gem -deprecated "exact phrase" since:2024-01-01')).to eq [
      "(subject LIKE ? OR body LIKE ?) AND " \
      "(subject LIKE ? OR body LIKE ?) AND " \
      "NOT ((subject LIKE ? OR body LIKE ?)) AND " \
      "(subject = ? OR body = ?) AND " \
      "date >= ?",
      [
        "ruby%",
        "%ruby%",
        "gem%",
        "%gem%",
        "deprecated%",
        "%deprecated%",
        "exact phrase",
        "exact phrase",
        "2024-01-01"
      ]
    ]
  end
end
