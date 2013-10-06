module ModelMacros

  # Create a new model class
  # @note taken from https://github.com/mirego/partisan/blob/master/spec/support/macros/model_macros.rb
  def spawn_class(klass_name, parent_klass, &block)
    Object.instance_eval { remove_const klass_name } if Object.const_defined?(klass_name)
    Object.const_set(klass_name, Class.new(parent_klass))
    Object.const_get(klass_name).class_eval(&block) if block_given?
  end
end
