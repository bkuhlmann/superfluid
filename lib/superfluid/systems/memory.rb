# frozen_string_literal: true

module Superfluid
  module Systems
    # An in-memory file system for storing templates.
    Memory = Data.define :templates do
      def initialize templates: {}
        super
      end

      def register name, content
        templates[name.to_s] = content
        self
      end

      def read_template_file name
        templates.fetch(name) { fail Liquid::FileSystemError, "Template not found: #{name}." }
      end
    end
  end
end
