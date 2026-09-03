# frozen_string_literal: true

require "containable"
require "spec_helper"

RSpec.describe Superfluid::Registries::Tag do
  subject(:registry) { described_class.new Module.new.extend(Containable), defaults: {} }

  describe "#initialize" do
    subject(:registry) { described_class.new }

    it "configures default tags" do
      expect(registry.names).to include("assign", "template")
    end
  end

  describe "#add" do
    it "add single tag" do
      registry.add test: Object
      expect(registry.names).to eq(["test"])
    end

    it "add multiple tags" do
      registry.add one: Object, two: Object
      expect(registry.names).to eq(%w[one two])
    end

    it "ignores duplicate key" do
      registry.add test: Object
      registry.add test: Object

      expect(registry.get(:test)).to eq(Object)
    end

    it "answers itself when key exists" do
      expect(registry.add(test: Object)).to be_a(described_class)
    end
  end

  describe "#merge" do
    it "merges other container" do
      other = Module.new.extend(Containable).register(:one, 1).register(:two, 2)
      registry.merge other

      expect(registry.names).to eq(%w[one two])
    end

    it "merges other container with specific dependencies" do
      other = Module.new.extend(Containable).register(:one, 1).register(:two, 2)
      registry.merge other, :one

      expect(registry.names).to eq(%w[one])
    end

    it "answers itself" do
      other = Module.new.extend Containable
      registry.merge other

      expect(registry.merge(other)).to be_a(described_class)
    end
  end

  describe "#get" do
    it "answers tag when found by name" do
      registry.add test: Object
      expect(registry.get(:test)).to eq(Object)
    end

    it "answers nil when not found" do
      expect(registry.get(:test)).to be(nil)
    end
  end

  describe "#names" do
    it "answers registered command" do
      registry.add test: Object
      expect(registry.names).to include("test")
    end

    it "answers empty array when commands don't exist" do
      expect(registry.names).to eq([])
    end
  end

  describe "#to_h" do
    it "answers hash" do
      registry.add test: Object
      expect(registry.to_h).to eq("test" => Object)
    end
  end
end
