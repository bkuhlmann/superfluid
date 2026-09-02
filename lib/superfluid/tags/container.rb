# frozen_string_literal: true

require "containable"

module Superfluid
  module Tags
    # A container of tag dependencies.
    module Container
      extend Containable

      register :template, Template
    end
  end
end
