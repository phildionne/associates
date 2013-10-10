require 'active_support/concern'

require 'associates/version'
require 'associates/persistence'
require 'associates/validations'

module Associates
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    include Persistence
    include Validations

    class_attribute :associates, instance_writer: false
    self.associates = Array.new
  end


  Item = Struct.new(:name, :klass, :attribute_names, :dependent_names, :options)

  module ClassMethods

    # Defines an associated model
    #
    # @example
    #   class User
    #     include Associates
    #
    #     associate :user, only: :username
    #   end
    #
    # @param model [Symbol, Class]
    # @param [Hash] options
    # @option options [Symbol, Array] :only Only generate methods for the given attributes
    #
    # @option options [Symbol, Array] :except Generate all the model's methods except
    #   for the given attributes
    #
    # @option options [Symbol] :depends_on Specify one or more associate name on
    #   which the current associate model depends to be valid. This is primarily
    #   a feature to automatically setup `belongs_to` associations between ActiveRecord
    #   models.
    #
    # @option options [String, Class] :class_name Specify the class name of the associate.
    #   Use it only if that name can’t be inferred from the associate's name
    #
    # @option options [Boolean] :delegate (true) Wether or not to delegate the associate's
    #   attributes getter and setters methods to the associate instance
    def associate(model, options = {})
      options = {
        delegate: true
      }.merge(options)

      associate = build_associate(model, options)
      self.associates << associate

      define_associate_delegation(associate) if options[:delegate]
      define_associate_instance_setter_method(associate)
      define_associate_instance_getter_method(associate)
    end


    private

    # Builds an associate
    #
    # @param model [Symbol, Class]
    # @param options [Hash]
    # @return [Item]
    def build_associate(model, options = {})
      model_name             = model.to_s.underscore
      model_klass            = options[:class_name] || model.to_s.classify.constantize
      dependent_models_names = extract_attributes(options[:depends_on]) || []
      dependent_models_names = dependent_models_names.map(&:to_s)

      if options[:only]
        attribute_names = extract_attributes(options[:only])
      else
        excluded = ['id', 'updated_at', 'created_at', 'deleted_at']

        if options[:except]
          excluded << extract_attributes(options[:except]).map(&:to_s)
          excluded.flatten!
        end

        attribute_names = model_klass.attribute_names.reject { |name| excluded.include?(name) }
      end

      # Ensure associate name don't clash with already declared ones
      if associates.map(&:name).include?(model_name)
        raise NameError, "already defined associate name '#{model_name}' for #{name}(#{object_id})"
      end

      # Ensure associate attribute names don't clash with already declared ones
      if options[:delegate]
        attribute_names.each do |attribute_name|
          if associates.map(&:attribute_names).include?(attribute_name)
            raise NameError, "already defined attribute name '#{attribute_name}' for #{name}(#{object_id})"
          end
        end
      end

      # Ensure associate dependent names exists
      dependent_models_names.each do |dependent_name|
        unless associates.map(&:name).include?(dependent_name)
          raise NameError, "undefined associated model '#{dependent_name}' for #{name}(#{object_id})"
        end
      end

      Item.new(model_name, model_klass, attribute_names, dependent_models_names, options)
    end

    # Define associated model attribute methods delegation
    #
    # @param associate [Item]
    def define_associate_delegation(associate)
      methods = [associate.attribute_names, associate.attribute_names.map { |attr| "#{attr}=" }].flatten
      send(:delegate, *methods, to: associate.name)
    end

    # Define associated model instance setter method
    #
    # @example
    #
    #   @form_object.user = User.new
    #
    # @param associate [Item]
    def define_associate_instance_setter_method(associate)
      define_method "#{associate.name}=" do |object|
        unless object.is_a?(associate.klass)
          raise ArgumentError, "#{associate.klass}(##{associate.klass.object_id}) expected, got #{object.class}(##{object.class.object_id})"
        end

        instance_variable_set("@#{associate.name}", object)
      end
    end

    # Define associated model instance getter method
    #
    # @example
    #
    #   @form_object.user
    #
    # @param associate [Item]
    def define_associate_instance_getter_method(associate)
      define_method associate.name do
        instance_variable_get("@#{associate.name}") || instance_variable_set("@#{associate.name}", associate.klass.new)
      end
    end

    # Allow to accept single or multiple elements as arguments. Ensures a collection
    # is always returned when there is one or more elements.
    #
    # @return [Nil, Array]
    def extract_attributes(object)
      return nil if object.blank?
      object.is_a?(Enumerable) ? object : [object]
    end
  end
end
