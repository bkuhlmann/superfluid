# frozen_string_literal: true

module Superfluid
  module Registries
    # The default tag registry.
    class Tag
      def initialize container = Tags::Container, defaults: Liquid::Tags::STANDARD_TAGS
        @container = container

        add(**defaults)
      end

      def add **collection
        collection.each { |name, tag| container.register name, tag unless container.key? name }
        self
      end

      def merge(other, *)
        container.merge(other, *)
        self
      end

      def get(name) = (container[name] if container.key? name)

      def names = container.keys

      def to_h = container.each.to_h

      private

      attr_reader :container
    end
  end
end
