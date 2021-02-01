# Load the Redmine helper
require "minitest/reporters"
require 'json'
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

Minitest::Reporters.use! [Minitest::Reporters::JUnitReporter.new, Minitest::Reporters::DefaultReporter.new]

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
  def assert_contains settings, key, value
    contains_kv_pair, message = contains_setting_with_value(settings, key, value)
    assert contains_kv_pair, message
  end
  def assert_contains_entry(collection, pairs = Hash.new)
    contains_kv_pair = true
    collection.each do |entry|
      contains_kv_pair = true
      pairs.each do |kv_pair|
        key, value = kv_pair
        contains_kv_pair &&= entry[key] == value
      end
      break if contains_kv_pair
    end
    assert contains_kv_pair, "the collection does not contain an entry with the given fields: %s" % pairs
  end
end

def contains_setting_with_value(settings, key, value)
  return false, "the given set of setting is empty" if settings.empty?
  settings.each do |setting|
    if setting['name'] == key && setting['value'] == value
      return true, ""
    end
  end
  [false, "the settings collection does not contain the key '#{key}' with the value '#{value}'"]
end

def contains_entry_with_value(collection, key, value)
  return false, "the given collection is empty" if collection.empty?
  collection.each do |entry|
    if entry[key] == value
      return true, ""
    end
  end
  [false, "the collection does not contain the key '#{key}' with the value '#{value}'"]
end