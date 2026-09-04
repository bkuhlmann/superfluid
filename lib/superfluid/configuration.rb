# frozen_string_literal: true

require "core"

module Superfluid
  # The default configuration.
  Configuration = Struct.new(
    :default_resource_limits,
    :error_mode,
    :exception_renderer,
    :file_system,
    :filter_registry,
    :tag_registry
  ) do
    def initialize(**)
      super

      self[:default_resource_limits] ||= Core::EMPTY_HASH
      self[:error_mode] ||= :strict
      self[:exception_renderer] ||= Core::Identity
      self[:file_system] ||= Systems::Memory.new
      self[:filter_registry] ||= Registries::Filter.new mode: error_mode
      self[:tag_registry] ||= Registries::Tag.new
    end
  end
end
