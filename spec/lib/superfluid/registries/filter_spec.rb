# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superfluid::Registries::Filter do
  subject(:registry) { described_class.new }

  let(:command) { proc { "test" } }

  before do
    registry.clear
    registry.add test: command
  end

  describe ".for" do
    it "answers for mode and registry" do
      expect(described_class.for).to be_a(described_class)
    end

    it "answers custom mode and registry" do
      namespace = Module.new do
        def test = "test"
      end

      expect(described_class.for(namespace, mode: :lax)).to have_attributes(
        mode: :lax,
        commands: {"test" => be_a(Method)}
      )
    end
  end

  describe "#add" do
    it "ignores duplicate key" do
      duplicate = proc { "duplicate" }

      expect(registry.add(test: duplicate)).to eq(described_class[commands: {"test" => command}])
    end

    it "answers itself when key exists" do
      expect(registry.add(test: command)).to be_a(described_class)
    end

    it "fails when command isn't callable" do
      expectation = proc { registry.add bogus: nil }
      expect(&expectation).to raise_error(Liquid::ArgumentError, /must be callable/)
    end

    it "adds namespace" do
      namespace = Module.new do
        def one = 1

        def two = 2
      end

      registry.add namespace

      expect(registry.commands).to match(
        "test" => command,
        "one" => be_a(Method),
        "two" => be_a(Method)
      )
    end

    it "adds namespaces" do
      one = Module.new { def one = 1 }
      two = Module.new { def two = 2 }

      registry.add one, two

      expect(registry.commands).to match(
        "test" => command,
        "one" => be_a(Method),
        "two" => be_a(Method)
      )
    end

    it "adds function" do
      other = proc { :other }

      expect(registry.add(other:)).to eq(
        described_class[commands: {"test" => command, "other" => other}]
      )
    end

    it "adds command" do
      implementation = Class.new do
        def initialize message = "test"
          @message = message
        end

        def call = @message
      end

      instance = implementation.new

      expect(registry.add(other: instance)).to eq(
        described_class[commands: {"test" => command, "other" => instance}]
      )
    end

    it "adds functions" do
      one = proc { 1 }
      two = proc { 2 }

      expect(registry.add(one:, two:)).to eq(
        described_class[commands: {"test" => command, "one" => one, "two" => two}]
      )
    end

    it "answers itself when key doesn't exist" do
      other = proc { :other }
      expect(registry.add(other:)).to be_a(described_class)
    end
  end

  shared_examples "a callable" do |method|
    it "messages command (symbol)" do
      expect(registry.public_send(method, :test)).to eq("test")
    end

    it "messages command (string)" do
      expect(registry.public_send(method, "test")).to eq("test")
    end

    it "messages command with arguments" do
      multiplier = -> first, second { first * second }
      registry.add(multiplier:)

      expect(registry.public_send(method, "multiplier", 5, 2)).to eq(10)
    end

    it "fails when key is missing and strict filters is enabled" do
      expectation = proc { registry.public_send method, :bogus }
      expect(&expectation).to raise_error(Liquid::UndefinedFilter, /bogus/)
    end

    it "fails with wrong arguments" do
      echo = -> text { text }
      registry.add(echo:)
      expectation = proc { registry.public_send method, :echo }

      expect(&expectation).to raise_error(Liquid::ArgumentError, /wrong number of arguments/)
    end

    it "answers nil when key isn't found, mode isn't strict, and no arguments" do
      registry = described_class[mode: :lax]
      expect(registry.public_send(method, :bogus)).to be(nil)
    end

    it "answers first argument when key isn't found, mode isn't strict, and has arguments" do
      registry = described_class[mode: :lax]
      expect(registry.public_send(method, :bogus, :one, :two)).to be(:one)
    end
  end

  describe "#call" do
    it_behaves_like "a callable", :call
  end

  describe "#invoke" do
    it_behaves_like "a callable", :invoke
  end

  describe "#names" do
    it "answers keys names commands exist" do
      expect(registry.names).to eq(["test"])
    end

    it "answers empty array when commands don't exist" do
      registry.commands.clear
      expect(registry.names).to eq([])
    end
  end
end
