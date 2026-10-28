# frozen_string_literal: true

module Superfluid
  module Tags
    # Define custom templates within the context of the current template.
    class Template < Liquid::Block
      NAME_PATTERN = %r(\A[0-9a-zA-Z_/]+\z)

      def initialize tag_name, markup, options
        super

        @name = markup.strip
        @content = +""
      end

      def parse tokens
        content.clear

        while (token = tokens.shift)
          return close token if end? token

          content << token
        end

        raise_tag_never_closed block_name
      end

      def render context
        unless NAME_PATTERN.match? name
          return "Liquid error: Invalid template name #{name.inspect} - template names " \
                 "must contain only letters, numbers, underscores, and forward slashes."
        end

        context.registers[:file_system].register name, content.strip
        ""
      end

      private

      attr_reader :name, :content

      def close(token) = parse_context.trim_whitespace = token.end_with?("-%}")

      def end?(token) = token.include? block_delimiter
    end
  end
end
