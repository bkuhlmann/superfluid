# frozen_string_literal: true

require "core"

module Superfluid
  # Renders template and associated data.
  class Renderer
    def initialize environment: Environment.new, parser: Liquid::Template
      @environment = environment
      @parser = parser

      yield environment if block_given?

      environment.freeze
    end

    def call(template, data = Core::EMPTY_HASH) = parser.parse(template, environment:).render data

    private

    attr_reader :environment, :parser
  end
end
