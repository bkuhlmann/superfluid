# frozen_string_literal: true

require "core"

module Superfluid
  # The default Liquid environment.
  Environment = Struct.new(
    :default_resource_limits,
    :error_mode,
    :exception_renderer,
    :file_system,
    :filter_registry,
    :tags
  ) do
    def self.for(**)
      instance = new(**)

      yield instance if block_given?

      instance.freeze
    end

    def self.default
      @default ||= new
    end

    def initialize(**)
      super

      self[:default_resource_limits] ||= Core::EMPTY_HASH
      self[:error_mode] ||= :strict
      self[:exception_renderer] ||= Core::Identity
      self[:file_system] ||= Systems::Memory.new
      self[:filter_registry] ||= Registries::Filter.for mode: error_mode
      self[:tags] ||= Liquid::Tags::STANDARD_TAGS.dup

      @filters_cache = {}
    end

    def create_filter_registry _context = nil,
                               filters = Core::EMPTY_ARRAY,
                               namespace: Liquid::StandardFilters
      return filter_registry if filters.empty?

      filter_registry.add(namespace, *filters)
    end

    alias_method :create_strainer, :create_filter_registry

    def filter_names = filter_registry.names

    alias_method :filter_method_names, :filter_names

    def register_filter(namespace, **)
      filters_cache.clear
      filter_registry.add(namespace, **)
      self
    end

    def register_filters(*, **)
      filters_cache.clear
      filter_registry.add(*, **)
      self
    end

    def register_tag name, klass
      tags[name.to_s] = klass
      self
    end

    def find_tag(name) = tags[name.to_s]

    alias_method :tag_for_name, :find_tag

    def freeze
      tags.freeze
      super
    end

    private

    attr_reader :filters_cache
  end
end
