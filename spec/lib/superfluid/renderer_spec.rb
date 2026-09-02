# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superfluid::Renderer do
  subject(:renderer) { described_class.new }

  describe "#initialize" do
    it "yields environment to block" do
      echoer = -> text { text }
      renderer = described_class.new { it.register_filters echo: echoer }
      template = %({{ "test" | echo }})

      expect(renderer.call(template)).to eq("test")
    end

    it "freeze environment" do
      environment = Superfluid::Environment.new
      described_class.new(environment:)

      expect(environment.frozen?).to be(true)
    end
  end

  describe "#call" do
    it "renders content" do
      expect(renderer.call("This is a: {{ message }}.", "message" => "test")).to eq(
        "This is a: test."
      )
    end
  end
end
