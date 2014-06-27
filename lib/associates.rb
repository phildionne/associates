require 'active_support/concern'

require 'associates/version'
require 'associates/persistence'
require 'associates/validations'

module Associates
  extend ActiveSupport::Concern

  included do
    if ActiveModel.version >= Gem::Version.new("4.0.0")
      include ActiveModel::Model
    else
      extend ActiveModel::Naming
      include ActiveModel::Validations
      include ActiveModel::Conversions
    end

    include Persistence
    include Validations

    class_attribute :associates, instance_writer: false
    self.associates = Array.new
  end

  BLACKLISTED_ATTRIBUTES = ['id', 'updated_at', 'created_at', 'deleted_at']
  # Convenience method to allow configuration options to be set in a block
  def self.configure(&block)
    yield self
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
    #   which the current associate model depends to be valid. Allow to automatically
    #   setup `belongs_to` associations between models
    #
    # @option options [String, Class] :class_name Specify the class name of the associate.
    #   Use it only if that name can’t be inferred from the associate's name
    #
    # @option options [Boolean] :delegate (true) Wether or not to delegate the associate's
    #   attributes getter and setters methods to the associate instance
    def associate(model, options = {})
      options[:only]       = Array(options[:only])
      options[:except]     = Array(options[:except])
      options[:depends_on] = Array(options[:depends_on])

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
      model_name                = model.to_s.underscore
      model_klass               = (options[:class_name] || model).to_s.classify.constantize
      dependent_associate_names = options[:depends_on].map(&:to_s)
      attribute_names           = extract_attribute_names(model_klass, options)

      ensure_name_uniqueness(associates.map(&:name), model_name)
      ensure_attribute_uniqueness(associates.map(&:attribute_names), attribute_names) if options[:delegate]
      ensure_dependent_names_existence(associates.map(&:name), dependent_associate_names)

      Item.new(model_name, model_klass, attribute_names, dependent_associate_names, options)
    end

    # Ensure associate name don't clash with already declared ones
    #
    # @param associates_names [Array]
    # @param name [String]
    def ensure_name_uniqueness(associates_names, name)
      if associates_names.include?(name)
        raise NameError, "already defined associate name '#{model_name}' for #{name}(#{object_id})"
      end
    end

    # Ensure associate attribute names don't clash with already declared ones
    #
    # @param associates_attribute_names [Array]
    # @param attribute_names [Array]
    def ensure_attribute_uniqueness(associates_attribute_names, attribute_names)
      attribute_names.each do |attribute_name|
        if associates_attribute_names.include?(attribute_name)
          raise NameError, "already defined attribute name '#{attribute_name}' for #{name}(#{object_id})"
        end
      end
    end

    # Ensure associate dependent names exists
    #
    # @param associates_names [Array]
    # @param dependent_associate_names [Array]
    def ensure_dependent_names_existence(associates_names, dependent_associate_names)
      dependent_associate_names.each do |dependent_name|
        unless associates_names.include?(dependent_name)
          raise NameError, "undefined associated model '#{dependent_name}' for #{name}(#{object_id})"
        end
      end
    end

    # @param model_klass [Class]
    # @param options [Hash]
    # @return [Array]
    def extract_attribute_names(model_klass, options)
      if options[:only].any?
        options[:only]
      else
        excluded = BLACKLISTED_ATTRIBUTES.to_a

        if options[:except].any?
          excluded += options[:except].map(&:to_s)
        end

        model_klass.attribute_names.reject { |name| excluded.include?(name) }
      end
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
    #   @association.user = User.new
    #
    # @param associate [Item]
    def define_associate_instance_setter_method(associate)
      define_method "#{associate.name}=" do |object|
        unless object.is_a?(associate.klass)
          raise ArgumentError, "#{associate.klass}(##{associate.klass.object_id}) expected, got #{object.class}(##{object.class.object_id})"
        end

        instance = instance_variable_set("@#{associate.name}", object)

        depending = associates.select { |_associate| _associate.dependent_names.include?(associate.name) }
        depending.each do |_associate|
          send(_associate.name).send("#{associate.name}=", instance)
        end

        instance
      end
    end

    # Define associated model instance getter method
    #
    # @example
    #
    #   @association.user
    #
    # @param associate [Item]
    def define_associate_instance_getter_method(associate)
      define_method associate.name do
        instance = instance_variable_get("@#{associate.name}") || instance_variable_set("@#{associate.name}", associate.klass.new)

        depending = associates.select { |_associate| _associate.dependent_names.include?(associate.name) }
        depending.each do |_associate|
          existing = send(_associate.name).send(associate.name)
          send(_associate.name).send("#{associate.name}=", instance) unless existing
        end

        instance
      end
    end
  end
end
