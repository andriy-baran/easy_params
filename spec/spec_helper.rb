require "bundler/setup"
require 'rspec_vars_helper'
require 'simplecov'
require 'pry'
SimpleCov.start do
  add_filter '/spec/'
end
require "easy_params"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.expose_dsl_globally = true
  config.include RspecVarsHelper
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
