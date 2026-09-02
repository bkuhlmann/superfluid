# frozen_string_literal: true

require "core"
require "functionable"

module Superfluid
  module Registries
    # The default filter registry.
    class Filter
      attr_reader :mode

      def initialize container = Filters::Container,
                     defaults: Liquid::StandardFilters,
                     mode: :strict
        @container = container
        @mode = mode

        add defaults
      end

      def add(*, **)
        add_namespaces(*)
        add_commands(**)
        self
      end

      def merge(other, *)
        container.merge(other, *)
        self
      end

      def call(name, *)
        dispatch(name, *)
      rescue ArgumentError => error
        raise Liquid::ArgumentError, error.message, error.backtrace
      end

      alias invoke call

      def names = container.keys

      private

      attr_reader :container

      def add_namespaces(*collection) = collection.each { add_methods it }

      def add_methods namespace
        # Order matters.
        case namespace
          in Class
            fail Liquid::ArgumentError,
                 "Invalid type (#{namespace}) for namespace. Must be a Module or Functionable."
          in Functionable then add_function_methods namespace
          in Module then add_instance_methods namespace
          # simplecov:disable
        end
      end

      def add_function_methods namespace
        namespace.function_methods
                 .each
                 .with_object({}) { |name, all| all[name] = namespace.method name }
                 .then { add_commands(**it) }
      end

      def add_instance_methods namespace
        shadow = Class.new.include(namespace).new

        collection = namespace.instance_methods
                              .each
                              .with_object({}) do |method, all|
                                name = method.name
                                all[name] = shadow.method name
                              end

        add_commands(**collection)
      end

      def add_commands(**collection) = collection.each { |name, command| add_command name, command }

      def add_command name, callable
        return if container.key? name

        case callable
          in Proc | Method | Core::Composable then container.register(name) { callable }
          else fail Liquid::ArgumentError, "Filter must be callable."
        end
      end

      def dispatch name, *arguments
        if container.key? name then container[name].call(*arguments)
        elsif mode == :strict then fail Liquid::UndefinedFilter, "Undefined filter: #{name}."
        else arguments.first
        end
      end
    end
  end
end
