require "sequel_couchbase_model/version"
require 'couchbase/model'

module Sequel
  module Couchbase
    class ValidationException < RuntimeError
      attr_reader :validation_errors

      def initialize validation_errors
        @validation_errors = validation_errors
      end
    end

    class Model < ::Couchbase::Model
      @@plugins = []

      def self.plugin(plugin, *args, &block)
        m = plugin.is_a?(Module) ? plugin : plugin_module(plugin)
        unless @@plugins.include?(m)
          @@plugins << m
          m.apply(self, *args, &block) if m.respond_to?(:apply)
          include(m::InstanceMethods) if plugin_module_defined?(m, :InstanceMethods)
          extend(m::ClassMethods) if plugin_module_defined?(m, :ClassMethods)
          dataset_extend(m::DatasetMethods) if plugin_module_defined?(m, :DatasetMethods)
        end
        m.configure(self, *args, &block) if m.respond_to?(:configure)
      end

      def self.plugin_module_defined?(plugin, submod)
        if RUBY_VERSION >= '1.9'
          plugin.const_defined?(submod, false)
        else
          # :nocov:
          plugin.const_defined?(submod)
          # :nocov:
        end
      end

      def self.plugin_module(plugin)
        module_name = plugin.to_s.gsub(/(^|_)(.)/) { |x| x[-1..-1].upcase }
        if !Sequel::Plugins.const_defined?(module_name) ||
            (Sequel.const_defined?(module_name) &&
                Sequel::Plugins.const_get(module_name) == Sequel.const_get(module_name))
          begin
            Sequel.tsk_require "sequel/plugins/#{plugin}"
          rescue LoadError => e
            begin
              Sequel.tsk_require "sequel_#{plugin}"
            rescue LoadError => e2
              e.message << "; #{e2.message}"
              raise e
            end
          end
        end
        Sequel::Plugins.const_get(module_name)
      end

      def self.blank_object?(obj)
        return obj.blank? if obj.respond_to?(:blank?)
        case obj
          when NilClass, FalseClass
            true
          when Numeric, TrueClass
            false
          when String
            obj.strip.empty?
          else
            obj.respond_to?(:empty?) ? obj.empty? : false
        end
      end

      def blank_object?
        self.class.blank_object? self
      end

      def self.db
        self
      end

      def self.find! id
        super id
      end

      def self.find id
        begin
          super id
        rescue Couchbase::Error::NotFound
          nil
        end
      end

      def valid?
        errors.blank?
      end

      def save options = {}
        save_ex options, ->(options) { super options }, ->() { false }
      end

      def save! options = {}
        save_ex options, ->(options) { super options }, ->() {
          raise ValidationException.new(@errors), "Could not save #{self.class.name} model due to failing validation: #{errors.inspect}\n\tmodel was: #{inspect}"
        }
      end

      def disable_update_timestamps!
        @auto_timestamps_disabled = true
      end

      def errors
        @errors ||= Sequel::Model::Errors.new
      end

      protected
      def before_save
      end

      def after_save
      end

      def before_validate
      end

      def validate
        true
      end

      private
      def save_ex options={}, on_save, on_failure
        errors.clear
        update_timestamps!
        before_validate
        validate

        if valid?
          before_save
          on_save.call options
          after_save
          true
        else
          on_failure.call
        end
      end


      def update_timestamps!
        unless @auto_timestamps_disabled
          begin
            self.created_at ||= Time.now.to_i #doing if attributes.include? :created_at doesn't seem to always work
          rescue NoMethodError
          end

          begin
            self.updated_at = Time.now.to_i #doing if attributes.include? :updated_at doesn't seem to always work
          rescue NoMethodError
          end
        end
      end
    end

  end
end
