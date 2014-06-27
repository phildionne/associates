require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
require 'rspec'
require 'sqlite3'

require 'associates'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].map(&method(:require))
Dir["#{File.dirname(__FILE__)}/factories.rb"].map(&method(:require))

RSpec.configure do |config|

  config.include DatabaseMacros
  config.include ModelMacros

  config.filter_run focus: true
  config.filter_run_excluding skip: true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    Database.setup
  end

  config.after(:each) do
    Database.clean
  end
end
