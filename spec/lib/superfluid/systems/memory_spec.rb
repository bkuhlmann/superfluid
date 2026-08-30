# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superfluid::Systems::Memory do
  subject(:system) { described_class.new }

  describe "#register" do
    it "registers template (symbol)" do
      system.register :test, "Test content."
      expect(system.templates).to eq("test" => "Test content.")
    end

    it "registers template (string)" do
      system.register "test", "Test content."
      expect(system.templates).to eq("test" => "Test content.")
    end

    it "answes itself" do
      expect(system.register("test", "Test content.")).to be_a(described_class)
    end
  end

  describe "#read_template_file" do
    it "reads template" do
      system.register "test", "Test content."
      expect(system.read_template_file("test")).to eq("Test content.")
    end

    it "fails with file system error when template can't be found" do
      expectation = proc { system.read_template_file :bogus }

      expect(&expectation).to raise_error(
        Liquid::FileSystemError,
        "Liquid error: Template not found: bogus."
      )
    end
  end
end
