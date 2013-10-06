require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
require 'rspec'
require 'sqlite3'

require 'associates'

Dir[File.expand_path('../../spec/support/*.rb', __FILE__)].map(&method(:require))
Dir[File.expand_path('../../spec/support/macros/*.rb', __FILE__)].map(&method(:require))
Dir[File.expand_path('../../spec/support/shared/*.rb', __FILE__)].map(&method(:require))
require File.expand_path('../../spec/factories.rb', __FILE__)

RSpec.configure do |config|

  config.include DatabaseMacros
  config.include ModelMacros

  config.treat_symbols_as_metadata_keys_with_true_values = true
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
