# frozen_string_literal: true

require "containable"

module Superfluid
  # A custom register which allows key overrides.
  class Register < Containable::Register
    def call key, value = nil, as: :cache, &block
      dependencies[namespacify(key)] = [block || value, as]
    end
  end
end
