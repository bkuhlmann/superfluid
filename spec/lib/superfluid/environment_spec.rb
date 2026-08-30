# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superfluid::Environment do
  subject(:environment) { described_class.new }

  describe ".for" do
    it "answers new instance" do
      expect(described_class.for).to be_a(described_class)
    end

    it "answers new instance with custom settings" do
      exception_renderer = proc { "error" }
      file_system = Object.new
      filter_registry = Object.new
      tags = {test: 1}

      instance = described_class.for(
        error_mode: :lax,
        exception_renderer:,
        file_system:,
        filter_registry:,
        tags:
      )

      expect(instance).to have_attributes(
        error_mode: :lax,
        exception_renderer:,
        file_system:,
        filter_registry:,
        tags:
      )
    end

    it "yields block" do
      instance = described_class.for { it.error_mode = :lax }
      expect(instance.error_mode).to eq(:lax)
    end

    it "answers frozen instance" do
      instance = described_class.for
      expect(instance.frozen?).to be(true)
    end
  end

  describe ".default" do
    it "answers default instance" do
      expect(described_class.default).to be_a(described_class)
    end
  end

  describe "#initialize" do
    it "answers new instance" do
      expect(described_class.new).to be_a(described_class)
    end

    it "answers default configuration" do
      expect(described_class.new).to have_attributes(
        default_resource_limits: Core::EMPTY_HASH,
        error_mode: :strict,
        exception_renderer: Core::Identity,
        file_system: Superfluid::Systems::Memory.new,
        filter_registry: be_a(Superfluid::Registries::Filter),
        tags: be_a(Hash)
      )
    end

    it "answers custom configuration" do
      fake = Object.new

      instance = described_class[
        default_resource_limits: fake,
        error_mode: :lax,
        exception_renderer: fake,
        file_system: fake,
        filter_registry: fake,
        tags: {}
      ]

      expect(instance).to have_attributes(
        default_resource_limits: fake,
        error_mode: :lax,
        exception_renderer: fake,
        file_system: fake,
        filter_registry: fake,
        tags: {}
      )
    end
  end

  shared_examples "a filter register" do |method|
    it "answers filter register instance" do
      expect(environment.public_send(method)).to be_a(Superfluid::Registries::Filter)
    end

    it "answers filter register instance with filters" do
      namespace = Module.new { def one = 1 }
      filter_registry = environment.public_send method, nil, [namespace]

      expect(filter_registry.names).to include("one")
    end
  end

  describe "#create_filter_registry" do
    it_behaves_like "a filter register", :create_filter_registry
  end

  describe "#create_strainer" do
    it_behaves_like "a filter register", :create_strainer
  end

  shared_examples "a filter name collection" do |method|
    it "answers array" do
      expect(environment.public_send(method)).to include("find", "join", "upcase")
    end
  end

  describe "#filter_names" do
    it_behaves_like "a filter name collection", :filter_names
  end

  describe "#filter_method_names" do
    it_behaves_like "a filter name collection", :filter_method_names
  end

  describe "#register_filter" do
    let(:test) { Module.new { def test = "test" } }

    it "adds namespace" do
      environment.register_filter test
      expect(environment.filter_method_names).to include("test")
    end

    it "adds namespace and command" do
      function = proc { "test" }
      environment.register_filter test, other: function

      expect(environment.filter_method_names).to include("test", "other")
    end

    it "answers itself" do
      expect(environment.register_filter(test)).to be_a(described_class)
    end
  end

  describe "#register_filters" do
    let :modules do
      one = Module.new { def one = "one" }
      two = Module.new { def two = "two" }

      [one, two]
    end

    it "adds namespaces" do
      environment.register_filters(*modules)
      expect(environment.filter_method_names).to include("one", "two")
    end

    it "adds namespaces and commands" do
      three = proc { "three" }
      four = proc { "four" }

      environment.register_filters(*modules, three:, four:)
      expect(environment.filter_method_names).to include("one", "two", "three", "four")
    end

    it "answers itself" do
      expect(environment.register_filters(*modules)).to be_a(described_class)
    end
  end

  describe "#register_tag" do
    it "adds tag (symbol)" do
      environment.register_tag :test, Object
      expect(environment.tags).to include("test" => Object)
    end

    it "adds tag (string)" do
      environment.register_tag "test", Object
      expect(environment.tags).to include("test" => Object)
    end

    it "answers itself" do
      expect(environment.register_tag(:test, Object)).to be_a(described_class)
    end
  end

  shared_examples "a tag finder" do |method|
    it "answers tag (symbol)" do
      expect(environment.public_send(method, :assign)).to eq(Liquid::Assign)
    end

    it "answers tag (string)" do
      expect(environment.public_send(method, "assign")).to eq(Liquid::Assign)
    end
  end

  describe "find_tag" do
    it_behaves_like "a tag finder", :find_tag
  end

  describe "#tag_for_name" do
    it_behaves_like "a tag finder", :tag_for_name
  end

  describe "#freeze" do
    it "answers frozen instance" do
      expect(environment.freeze.frozen?).to be(true)
    end

    it "freezes tags" do
      environment.freeze
      expect(environment.tags.frozen?).to be(true)
    end

    it "answers itself" do
      expect(environment.freeze).to be_a(described_class)
    end
  end
end
