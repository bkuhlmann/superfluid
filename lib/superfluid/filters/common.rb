# frozen_string_literal: true

module Superfluid
  # Custom filters.
  module Filters
    require "functionable"

    # Shared primitive behavior.
    module Common
      extend Functionable

      def append target, suffix
        case target
          when Array then target.dup.append suffix
          when String then "#{target}#{suffix}"
          else fail Liquid::ArgumentError, "Unsupported type: #{target.class}."
        end
      end

      def prepend target, prefix
        case target
          when Array then target.dup.prepend prefix
          when String then "#{prefix}#{target}"
          else fail Liquid::ArgumentError, "Unsupported type: #{target.class}."
        end
      end
    end
  end
end
