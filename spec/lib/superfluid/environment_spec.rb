# frozen_string_literal: true

require "containable"
require "spec_helper"

RSpec.describe Superfluid::Environment do
  subject(:environment) { described_class.new }

  describe ".default" do
    it "answers default instance" do
      expect(described_class.default).to be_a(described_class)
    end
  end

  describe ".for" do
    it "answers custom configuratoin" do
      instance = described_class.for error_mode: :lax
      expect(instance.error_mode).to eq(:lax)
    end

    it "yields block" do
      instance = described_class.for { it.error_mode = :lax }
      expect(instance.error_mode).to eq(:lax)
    end
  end

  describe "#initialize" do
    it "yields block" do
      instance = described_class.new { it.error_mode = :lax }
      expect(instance.error_mode).to eq(:lax)
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

  describe "#merge_filters" do
    it "merges other container" do
      other = Module.new.extend(Containable).register(:merge_a, 1).register(:merge_b, 2)
      environment.merge_filters other, :merge_a

      expect(environment.filter_names).not_to include("merge_b")
    end

    it "answers itself" do
      other = Module.new.extend Containable
      expect(environment.merge_filters(other)).to be_a(described_class)
    end
  end

  describe "#merge_tags" do
    it "merges other container" do
      other = Module.new.extend(Containable).register(:merge_a, 1)
      environment.merge_tags other, :merge_a

      expect(environment.filter_names).not_to include("merge_b")
    end

    it "answers itself" do
      other = Module.new.extend Containable
      expect(environment.merge_tags(other)).to be_a(described_class)
    end
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
    it "adds tag" do
      environment.register_tag :test, Object
      expect(environment.tags).to include("test" => Object)
    end

    it "answers itself" do
      expect(environment.register_tag(:test, Object)).to be_a(described_class)
    end
  end

  describe "#register_tags" do
    it "adds tags" do
      environment.register_tags one: Object, two: Object
      expect(environment.tags).to include("one" => Object, "two" => Object)
    end

    it "answers itself" do
      expect(environment.register_tags).to be_a(described_class)
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

    it "answers itself" do
      expect(environment.freeze).to be_a(described_class)
    end
  end
end
