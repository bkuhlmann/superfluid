# frozen_string_literal: true

require "containable"
require "core"
require "json"
require "refinements/string"

module Superfluid
  module Filters
    # A container of filter dependencies.
    module Container
      extend Containable

      using Refinements::String

      register(:jsonify) { |value| JSON.generate value }
      register(:parse_json) { |value| JSON.parse value }

      register :pluralize do |value, count = 0, suffix = "s", replace = /$/|
        "#{count} #{value.pluralize suffix, count, replace:}"
      end

      register :singularize do |value, count = 0, suffix = "s", replace = Core::EMPTY_STRING|
        "#{count} #{value.singularize suffix, count, replace:}"
      end

      register :trim_end do |value, maximum, trailer = "..."|
        value.trim_end maximum, nil, trailer:
      end

      register(:trim_middle) { |value, maximum, gap = "..."| value.trim_middle maximum, gap: }
    end
  end
end
