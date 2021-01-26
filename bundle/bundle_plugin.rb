require 'fileutils'

PLUGIN_DIR="redmine_extended_rest_api"
FileUtils.mkdir_p(PLUGIN_DIR)
filenames = Dir.entries("../")
FileUtils.cp"../Gemfile", PLUGIN_DIR + "/Gemfile", :verbose => true
FileUtils.cp"../init.rb", PLUGIN_DIR + "/init.rb", :verbose => true
FileUtils.cp_r "../app/.", PLUGIN_DIR + "/app", :verbose => true
FileUtils.cp_r "../assets/.", PLUGIN_DIR + "/assets", :verbose => true
FileUtils.cp_r "../config/.", PLUGIN_DIR + "/config", :verbose => true
FileUtils.cp_r "../db/.", PLUGIN_DIR + "/db", :verbose => true
FileUtils.cp_r "../lib/.", PLUGIN_DIR + "/lib", :verbose => true

