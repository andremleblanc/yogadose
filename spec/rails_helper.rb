ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'capybara/rspec'
require 'vcr'

Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include RequestSpecHelper, type: :request
  config.include FeatureSpecHelper, type: :feature
  config.around(:each, type: :feature) do |ex|
    if ex.metadata.key?(:vcr)
      ex.run
    else
      WebMock.allow_net_connect!
      VCR.turned_off {ex.call}
      WebMock.disable_net_connect!
    end
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.allow_http_connections_when_no_cassette = false
  config.ignore_localhost = true
end
