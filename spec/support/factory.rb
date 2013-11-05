class Factory
  cattr_accessor :factories, instance_writer: false

  self.factories = Hash.new { |hash, key| hash[key] = {} }

  def self.define(name, options = {}, &block)
    self.factories[name][:options]    = options
    self.factories[name][:definition] = block
  end

  def self.build(name, attributes = {})
    new(name, attributes).record
  end

  def self.create(name, attributes = {})
    record = new(name, attributes).record
    record.save!
    record
  end

  def self.attributes_for(name, attributes = {})
    new(name, attributes).record.to_h
  end

  attr_accessor :record

  def initialize(name, attributes = {})
    definition  = factories[name][:definition]
    klass       = factories[name][:options][:class] || name
    self.record = klass.to_s.classify.constantize.new

    record.instance_eval(&definition)

    # @FIXME Works except with transient attributes
    attributes.each do |key, value|
      record.send("#{key}=", value)
    end
  end
end
