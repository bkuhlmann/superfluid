# frozen_string_literal: true

require "containable"
require "spec_helper"
require SPEC_ROOT.join("support/fixtures/functionable.rb").to_s

RSpec.describe Superfluid::Registries::Filter do
  subject(:registry) { described_class.new Module.new.extend(Containable), defaults: Module.new }

  let(:command) { proc { "test" } }

  describe "#initialize" do
    it "answers custom instance" do
      container = Module.new.extend(Containable).register(:one, 1)
      defaults = Module.new { def two = 2 }

      expect(described_class.new(container, defaults:, mode: :lax)).to have_attributes(
        mode: :lax,
        names: %w[one two]
      )
    end
  end

  describe "#add" do
    it "ignores duplicate key" do
      one = proc { "one" }
      two = proc { "two" }
      registry.add(test: one).add test: two

      expect(registry.call(:test)).to eq("one")
    end

    it "answers itself when key exists" do
      other = proc { "other" }
      expect(registry.add(test: other)).to be_a(described_class)
    end

    it "adds module namespace" do
      namespace = Module.new do
        def one = 1

        def two = 2
      end

      registry.add namespace

      expect(registry.names).to contain_exactly("one", "two")
    end

    it "adds module namespaces" do
      one = Module.new { def one = 1 }
      two = Module.new { def two = 2 }

      registry.add one, two

      expect(registry.names).to eq(%w[one two])
    end

    it "adds functionable namespace" do
      registry.add Test
      expect(registry.names).to eq(%w[one two])
    end

    it "adds proc" do
      other = proc { :other }
      registry.add(other:)

      expect(registry.names).to eq(%w[other])
    end

    it "adds proc and lambda" do
      one = proc { 1 }
      two = -> value { value }

      registry.add(one:, two:)

      expect(registry.names).to eq(%w[one two])
    end

    it "adds command" do
      implementation = Class.new do
        include Core::Composable

        def call = "test"
      end

      registry.add other: implementation.new

      expect(registry.names).to eq(%w[other])
    end

    it "answers itself when key doesn't exist" do
      other = proc { :other }
      expect(registry.add(other:)).to be_a(described_class)
    end

    it "fails when namespace isn't a Module or Functionable" do
      expectation = proc { registry.add String }

      expect(&expectation).to raise_error(
        Liquid::ArgumentError,
        /Invalid type \(String\) for namespace. Must be a Module or Functionable./
      )
    end

    it "fails when command isn't callable" do
      expectation = proc { registry.add bogus: nil }
      expect(&expectation).to raise_error(Liquid::ArgumentError, /must be callable/)
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

  shared_examples "a callable" do |method|
    it "messages command (symbol)" do
      registry.add test: command
      expect(registry.public_send(method, :test)).to eq("test")
    end

    it "messages command (string)" do
      registry.add test: command
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
      registry = described_class.new mode: :lax
      expect(registry.public_send(method, :bogus)).to be(nil)
    end

    it "answers first argument when key isn't found, mode isn't strict, and has arguments" do
      registry = described_class.new mode: :lax
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
    it "answers registered command" do
      registry.add test: command
      expect(registry.names).to include("test")
    end

    it "answers empty array when commands don't exist" do
      expect(registry.names).to eq([])
    end
  end
end
