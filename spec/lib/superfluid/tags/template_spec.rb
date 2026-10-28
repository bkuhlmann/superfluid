# frozen_string_literal: true

require "spec_helper"

RSpec.describe Superfluid::Tags::Template do
  subject :renderer do
    -> template, data { Liquid::Template.parse(template, environment:).render data }
  end

  let(:environment) { Superfluid.build { it.register_tag :template, described_class } }

  describe "#render" do
    it "answers content for registered template" do
      template = <<~LIQUID
        {% template test %}Hello, {{ name }}{% endtemplate %}
        {% render "test", name: "world" %}
        {% render "test", name: name %}
      LIQUID

      content = renderer.call template, {"name" => "test"}

      expect(content.strip).to eq("Hello, world\nHello, test")
    end

    it "answers content with template contents stripped" do
      template = "abc {% template test %}Hello, {{ name }}{% endtemplate %} 123"
      content = renderer.call template, {}

      expect(content).to eq("abc  123")
    end

    it "answers content with no whitespaces in end tag" do
      template = "{% template test %}Test{%endtemplate%}{% render 'test' %}"
      content = renderer.call template, {}

      expect(content).to eq("Test")
    end

    it "answers content with whitespaces in end tag" do
      template = "{% template test %}Test{%\n  endtemplate  \n%}{% render 'test' %}"
      content = renderer.call template, {}

      expect(content).to eq("Test")
    end

    it "answers content with trimmed end tag" do
      template = "{% template test %}Test{%- endtemplate -%}{% render 'test' %}"
      content = renderer.call template, {}

      expect(content).to eq("Test")
    end

    it "answers content with trimmed whitespace after trimmed end tag" do
      template = "{% template test %}Test{% endtemplate -%}\n  {% render 'test' %}"
      content = renderer.call template, {}

      expect(content).to eq("Test")
    end

    it "fails when end tag is missing" do
      expectation = proc { renderer.call "{% template my_template %}Hello", {} }
      expect(&expectation).to raise_error(Liquid::SyntaxError, /'template' tag was never closed/)
    end

    it "answers error with invalid template name" do
      content = renderer.call "{% template banger! %}Hello, world!{% endtemplate %}", {}

      expect(content).to eq(
        %(Liquid error: Invalid template name "banger!" - template names must contain only ) +
        %(letters, numbers, underscores, and forward slashes.)
      )
    end

    it "answers error for undefined template" do
      content = renderer.call %({% render "bogus" %}), {}
      expect(content).to eq("Liquid error: Template not found: bogus.")
    end
  end
end
