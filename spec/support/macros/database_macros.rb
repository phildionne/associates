module DatabaseMacros

  # @note Taken from https://github.com/mirego/partisan/blob/master/spec/support/macros/database_macros.rb
  def run_migration(&block)
    # Create a new migration class
    klass = Class.new(ActiveRecord::Migration)

    # Create a new `up` that executes the argument
    klass.send(:define_method, :up) { self.instance_exec(&block) }

    # Create a new instance of it and execute its `up` method
    klass.new.up
  end
end
