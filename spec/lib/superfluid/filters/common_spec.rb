# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superfluid::Filters::Common do
  subject(:filter) { described_class }

  describe "#append" do
    it "appends array" do
      expect(filter.append(%w[one two], "three")).to eq(%w[one two three])
    end

    it "appends string" do
      expect(filter.append("test", " suffix")).to eq("test suffix")
    end

    it "fails with unknown type" do
      expectation = proc { filter.append Hash.new, "suffix" }
      expect(&expectation).to raise_error(Liquid::ArgumentError, /Unsupported type: Hash\./)
    end
  end

  describe "#prepend" do
    it "prepends array" do
      expect(filter.prepend(%w[two three], "one")).to eq(%w[one two three])
    end

    it "prepends string" do
      expect(filter.prepend("test", "prefix ")).to eq("prefix test")
    end

    it "fails with unknown type" do
      expectation = proc { filter.prepend Hash.new, "prefix" }
      expect(&expectation).to raise_error(Liquid::ArgumentError, /Unsupported type: Hash\./)
    end
  end
end
