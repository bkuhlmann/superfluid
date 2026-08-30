# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superfluid do
  describe ".loader" do
    it "eager loads" do
      expectation = proc { described_class.loader.eager_load force: true }
      expect(&expectation).not_to raise_error
    end

    it "answers unique tag" do
      expect(described_class.loader.tag).to eq("superfluid")
    end
  end

  describe ".build" do
    it "answers instance with default configuration" do
      expect(described_class.build).to have_attributes(
        default_resource_limits: Core::EMPTY_HASH,
        error_mode: :strict,
        exception_renderer: Core::Identity,
        file_system: be_a(Superfluid::Systems::Memory),
        filter_registry: be_a(Superfluid::Registries::Filter),
        tags: hash_including("assign" => Liquid::Assign)
      )
    end

    it "answers instance with custom configuration" do
      environment = described_class.build error_mode: :strict
      expect(environment.error_mode).to eq(:strict)
    end

    it "yields to block" do
      instance = described_class.build { it.error_mode = :lax }
      expect(instance.error_mode).to eq(:lax)
    end
  end

  describe ".new" do
    it "answers renderer" do
      expect(described_class.new).to be_a(Superfluid::Renderer)
    end

    it "renders content" do
      renderer = described_class.new

      expect(renderer.call("This is a: {{ message }}.", "message" => "test")).to eq(
        "This is a: test."
      )
    end
  end
end
