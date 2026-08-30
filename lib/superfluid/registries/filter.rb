# frozen_string_literal: true

module Superfluid
  module Registries
    # A filter registry.
    Filter = Data.define :mode, :commands do
      def self.for(namespace = Liquid::StandardFilters, mode: :strict) = new(mode:).add namespace

      def initialize mode: :strict, commands: {}
        super
      end

      def add(*, **)
        add_namespaces(*)
        add_commands(**)
        self
      end

      def call(name, *)
        dispatch(name, *)
      rescue ArgumentError => error
        raise Liquid::ArgumentError, error.message, error.backtrace
      end

      alias_method :invoke, :call

      def clear
        commands.clear
        self
      end

      def names = commands.keys

      private

      def add_namespaces(*all) = all.each { add_methods it }

      def add_methods namespace
        shadow = Class.new.include(namespace).new

        all = namespace.instance_methods
                       .each
                       .with_object({}) do |method, all|
                         name = method.name
                         all[name] = shadow.method name
                       end

        add_commands(**all)
      end

      def add_commands(**all) = all.each { |name, command| add_command name, command }

      # :reek:ManualDispatch
      def add_command name, function
        key = name.to_s

        return if commands.key? key

        case function
          in Proc | Method | Object if function.respond_to? :call then commands[key] = function
          else fail Liquid::ArgumentError, "Filter must be callable."
        end
      end

      def dispatch name, *positionals
        key = name.to_s

        if commands.key? key
          commands[key].call(*positionals)
        elsif mode == :strict
          fail Liquid::UndefinedFilter, "Undefined filter: #{name}."
        else
          positionals.first
        end
      end
    end
  end
end
