# frozen_string_literal: true

require "core"
require "forwardable"

module Superfluid
  # The default environment.
  class Environment
    extend Forwardable

    def self.default
      @default ||= new
    end

    delegate Configuration.members => :configuration
    delegate Configuration.members.map { :"#{it}=" } => :configuration

    def self.for(configuration = Configuration, **, &) = new(configuration[**], &)

    def initialize configuration = Configuration.new
      @configuration = configuration

      yield self if block_given?
    end

    def create_filter_registry _context = nil, filters = Core::EMPTY_ARRAY
      filters.empty? ? filter_registry : filter_registry.add(*filters)
    end

    alias create_strainer create_filter_registry

    def filter_names = configuration.filter_registry.names

    alias filter_method_names filter_names

    def merge_filters(container, *)
      filter_registry.merge(container, *)
      self
    end

    def merge_tags(container, *)
      tag_registry.merge(container, *)
      self
    end

    def register_filter(*, **)
      filter_registry.add(*, **)
      self
    end

    def register_filters(*, **)
      filter_registry.add(*, **)
      self
    end

    def register_tag name, klass
      tag_registry.add name => klass
      self
    end

    def register_tags(**)
      tag_registry.add(**)
      self
    end

    def find_tag(name) = tags[name.to_s]

    alias tag_for_name find_tag

    def tags = tag_registry.to_h

    def freeze
      filter_registry.freeze
      tag_registry.freeze
      super
    end

    private

    attr_reader :configuration
  end
end
