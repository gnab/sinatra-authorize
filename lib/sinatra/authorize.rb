require 'sinatra/base'

module Sinatra
  module Authorize
    ALL_ARGS  = [:all, :any, :everybody, :everyone]
    NONE_ARGS = [:none, :nobody]

    class Condition < Proc; end

    def authorize(opts = {}, &block)
      opts = {opts => []} if opts.is_a?(Symbol)

      if opts[:deny]
        args = *(opts[:deny])
        set(:authorize_default, Proc.new {
          authorize_condition(:deny, args)
        })
      else
        args = *(opts[:allow] || [])
        set(:authorize_default, Proc.new {
          authorize_condition(:allow, args)
        })
      end

      if block_given?
        define_method(:authorize_do_block, block)
        authorize_do = instance_method(:authorize_do_block)
        remove_method(:authorize_do_block)

        set :authorize_do, Proc.new { authorize_do }
      end
    end

    def allow(*args)
      condition &(authorize_condition(:allow, args))
    end

    def deny(*args)
      condition &(authorize_condition(:deny, args))
    end

    def authorize_condition(kind, args)
      Condition.new { settings.authorize_do.bind(self).call(kind, args) }
    end

    class << self
      def registered(app)
        app.authorize do |kind, args|
          allow_default = lambda do |args|
            if args == [] || ALL_ARGS.include?(args.first)
              true
            elsif NONE_ARGS.include?(args.first)
              false
            else
              raise "Unknown authorization rule argument: #{args}."
            end
          end

          if kind == :allow
            allow_default.call(args)
          elsif kind == :deny
            !allow_default.call(args)
          else
            raise "Unknown authorization rule: #{kind}."
          end
        end

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
            conditions = conditions.dup
            conditions.unshift(settings.authorize_default)
            conditions = conditions.collect { |cond| instance_eval(&cond) }
            conditions.select { |allow| allow == true || allow == false }.last
          end
        end
      end
    end
  end

  register Authorize
end
