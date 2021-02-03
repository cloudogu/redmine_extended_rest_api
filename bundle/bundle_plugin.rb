#!/usr/bin/ruby

require 'fileutils'

PLUGIN_DIR="redmine_extended_rest_api"
FileUtils.mkdir_p(PLUGIN_DIR)
filenames = Dir.entries("../")
FileUtils.cp"../src/Gemfile", PLUGIN_DIR + "/Gemfile", :verbose => true
FileUtils.cp"../src/init.rb", PLUGIN_DIR + "/init.rb", :verbose => true
FileUtils.cp_r "../src/app/.", PLUGIN_DIR + "/app", :verbose => true
FileUtils.cp_r "../src/config/.", PLUGIN_DIR + "/config", :verbose => true
FileUtils.cp_r "../src/lib/.", PLUGIN_DIR + "/lib", :verbose => true
FileUtils.cp_r "../src/assets/.", PLUGIN_DIR + "/assets", :verbose => true

