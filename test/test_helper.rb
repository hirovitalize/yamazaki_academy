# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

ENV['SKIP_DB'] ||= ''
ActiveRecord::Base.maintain_test_schema = false if ENV['SKIP_DB'].present?

require 'rails/test_help'

module ActiveSupport
  class TestCase
    include Devise::Test::IntegrationHelpers

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end
