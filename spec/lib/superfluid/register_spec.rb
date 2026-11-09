# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superfluid::Register do
  subject(:register) { described_class.new }

  describe "#call" do
    it "overrides existing key" do
      register.call :test, "default"
      expect(register.call(:test, "override")).to eq(["override", :cache])
    end
  end
end
