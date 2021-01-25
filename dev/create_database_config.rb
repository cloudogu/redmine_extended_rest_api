#!/usr/bin/ruby

require 'erb'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: create_database_config.rb [options]"
  opts.on('-h', '--host HOST', 'Host name or ip address of the database server') { |v| options[:host] = v }
  opts.on('-f', '--path PATH', 'Path where the configuration file will be created') { |v| options[:path] = v }
end.parse!

if !options[:path] || options[:path] == '.'
  target_file = "database.yml"
else
  target_file = options[:path]
end
puts "Generating database.yml with host '#{options[:host]}' at '#{target_file}'"

template = ERB.new(File.read('database.yml.erb'))
config_file_content = template.result_with_hash(host: options[:host])
File.write(target_file, config_file_content)