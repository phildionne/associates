require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
require 'rspec'
require 'sqlite3'
require 'database_cleaner'

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

    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
