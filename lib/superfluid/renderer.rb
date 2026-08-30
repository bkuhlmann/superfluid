# frozen_string_literal: true

module Superfluid
  # Renders template and associated data.
  class Renderer
    def initialize environment: Environment.for, parser: Liquid::Template
      @environment = environment
      @parser = parser
    end

    def call(template, data) = parser.parse(template, environment:).render data

    private

    attr_reader :environment, :parser
  end
end
