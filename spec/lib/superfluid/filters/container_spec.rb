# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superfluid::Filters::Container do
  subject(:container) { described_class }

  describe "#jsonify" do
    it "answers JSON" do
      value = [:one, "two", 3, {d: :four}]
      expect(container[:jsonify].call(value)).to eq(value.to_json)
    end
  end

  describe "#parse_json" do
    it "answers hash" do
      content = [:one, "two", 3, {d: :four}].to_json
      expect(container[:parse_json].call(content)).to eq(["one", "two", 3, {"d" => "four"}])
    end
  end

  describe "#pluralize" do
    it "answers plural when count is zero" do
      expect(container[:pluralize].call("book")).to eq("0 books")
    end

    it "answers singular when count is one" do
      expect(container[:pluralize].call("book", 1)).to eq("1 book")
    end

    it "answers plural when count is more than one" do
      expect(container[:pluralize].call("book", 2)).to eq("2 books")
    end

    it "answers plural for complex word" do
      expect(container[:pluralize].call("octopus", 3, "i", "us")).to eq("3 octopi")
    end

    it "answers singular for complex word" do
      expect(container[:pluralize].call("person", 3, "ople", "rson")).to eq("3 people")
    end

    it "answers plural for alternate pluralization" do
      expect(container[:pluralize].call("person", 3, "humans", "person")).to eq("3 humans")
    end
  end

  describe "#singularize" do
    it "answers plural by default" do
      expect(container[:singularize].call("apples")).to eq("0 apples")
    end

    it "answers plural when count is zero" do
      expect(container[:singularize].call("apples", 0)).to eq("0 apples")
    end

    it "answers singular when count is one" do
      expect(container[:singularize].call("apples", 1)).to eq("1 apple")
    end

    it "answers plural when count is greater than one" do
      expect(container[:singularize].call("apples", 2)).to eq("2 apples")
    end

    it "answers singular with replacement" do
      expect(container[:singularize].call("cacti", 1, "i", "us")).to eq("1 cactus")
    end
  end

  describe "#trim_end" do
    let(:string) { "This is a test example." }

    it "answers original string when smaller than maximum" do
      expect(container[:trim_end].call("A test.", 10)).to eq("A test.")
    end

    it "answers trimmed string when larger than maximum" do
      expect(container[:trim_end].call(string, 10)).to eq("This is...")
    end

    it "answers trimmed string with custom trailer" do
      expect(container[:trim_end].call(string, 10, "---")).to eq("This is---")
    end
  end

  describe "#trim_middle" do
    let(:string) { "This is a test." }

    it "answers original string when smaller than maximum" do
      expect(container[:trim_middle].call(string, 20)).to eq("This is a test.")
    end

    it "answers trimmed string when larger than maximum" do
      expect(container[:trim_middle].call(string, 13)).to eq("This...test.")
    end

    it "answers trimmed string with custom gap" do
      expect(container[:trim_middle].call(string, 13, "--")).to eq("This--test.")
    end
  end
end
