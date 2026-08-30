# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.new.then do |loader|
  loader.tag = File.basename __FILE__, ".rb"
  loader.push_dir __dir__
  loader.setup
end

# Main namespace.
module Superfluid
  def self.loader registry = Zeitwerk::Registry
    @loader ||= registry.loaders.each.find do |loader|
      loader.tag == File.basename(__FILE__, ".rb")
    end
  end
end
