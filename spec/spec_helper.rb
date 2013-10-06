require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
require 'rspec'
require 'sqlite3'

require 'associates'

Dir[File.expand_path('../../spec/support/*.rb', __FILE__)].map(&method(:require))
Dir[File.expand_path('../../spec/support/macros/*.rb', __FILE__)].map(&method(:require))

RSpec.configure do |config|

  config.include DatabaseMacros

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:suite) do
    Database.setup

  end

  config.before(:each) do
  end

  config.after(:each) do
  end
end
