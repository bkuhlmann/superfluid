# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superfluid::Renderer do
  subject(:renderer) { described_class.new }

  describe "#call" do
    it "renders content" do
      expect(renderer.call("This is a: {{ message }}.", "message" => "test")).to eq(
        "This is a: test."
      )
    end
  end
end
