# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superfluid::Configuration do
  subject(:configuration) { described_class.new }

  describe "#initialize" do
    it "answers default configuration" do
      expect(described_class.new).to have_attributes(
        default_resource_limits: Core::EMPTY_HASH,
        error_mode: :strict,
        exception_renderer: Core::Identity,
        file_system: be_a(Superfluid::Systems::Memory),
        filter_registry: be_a(Superfluid::Registries::Filter),
        tag_registry: be_a(Superfluid::Registries::Tag)
      )
    end

    it "answers custom configuration" do
      exception_renderer = proc { "error" }
      fake = Object.new

      instance = described_class.new default_resource_limits: fake,
                                     error_mode: :lax,
                                     exception_renderer:,
                                     file_system: fake,
                                     filter_registry: fake,
                                     tag_registry: {}

      expect(instance).to have_attributes(
        default_resource_limits: fake,
        error_mode: :lax,
        exception_renderer:,
        file_system: fake,
        filter_registry: fake,
        tag_registry: {}
      )
    end
  end
end
