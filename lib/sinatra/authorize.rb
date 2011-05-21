require 'sinatra/base'

module Sinatra
  module Authorize
    class Condition < Proc
      attr_reader :rule
      def initialize(rule, &block)
        @rule = rule
        super(&block)
      end
    end

    def authorize(opts = {}, &block)
      opts = {opts => []} if opts.is_a?(Symbol)

      if opts[:deny]
        args = *(opts[:deny])
        set :authorize_default, Proc.new { authorize_condition(:deny, args) }
      else
        args = *(opts[:allow] || [])
        set :authorize_default, Proc.new { authorize_condition(:allow, args) }
      end

      if block_given?
        define_method(:authorize_block, block)
        authorize_block = instance_method(:authorize_block)
        remove_method(:authorize_block)

        set :authorize_block, Proc.new { authorize_block }
      end
    end

    def allow(*args)
      condition &(authorize_condition(:allow, args))
    end

    def deny(*args)
      condition &(authorize_condition(:deny, args))
    end

    def authorize_condition(rule, args)
      Condition.new rule do
        settings.authorize_block.bind(self).call(rule, args) 
      end
    end

    class << self
      def registered(app)
        app.class_eval do
          alias :old_process_route :process_route

          def process_route(pattern, keys, conditions, &block)
            authorize_conditions = conditions.select do |cond|
              cond.is_a?(Authorize::Condition)
            end

            regular_conditions = conditions - authorize_conditions

            old_process_route(pattern, keys, regular_conditions) do
              throw :halt, 403 if authorize_route(authorize_conditions) == false
              yield
            end
          end

          def authorize_route(conditions)
            unless settings.respond_to? :authorize_block
              raise "No authorize block is defined."
            end

            [settings.authorize_default, *conditions].reverse.each do |cond|
              value = instance_eval(&cond)
              return value if value == true || value == false
            end

            settings.authorize_default.rule == :allow
          end
        end
      end
    end
  end

  register Authorize
end
