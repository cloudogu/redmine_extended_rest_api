# Load the Redmine helper
require "minitest/reporters"
require 'json'
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

# Minitest::Reporters.use! [Minitest::Reporters::JUnitReporter.new]

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveRecord::Base.logger.level = :warn

class ActiveSupport::TestCase
  self.fixture_path = File.dirname(__FILE__) + '/fixtures'
end

class ActionDispatch::TestResponse
  def json_body
    JSON.parse(body)
  end
end

module MiniTest::Assertions
  def assert_contains collection, key, value
    contains_kv_pair, message = contains_setting_with_value(collection, key, value)
    assert contains_kv_pair, message
  end
end

def contains_setting_with_value(settings, key, value)
  return false, "the given settings are empty" if settings.empty?
  settings.each do |setting|
    if setting['name'] == key && setting['value'] == value
      return true, ""
    end
  end
  [false, "settings does not contain the key '#{key}' with the value '#{value}'"]
end