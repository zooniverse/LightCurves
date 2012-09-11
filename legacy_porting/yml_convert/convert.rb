require './hashToCS.rb'
require 'yaml'

# quick and dirty script to convert PH YAML file to coffeescript
# Disclaimer: I barely know any ruby, so this is not supposed to be good code
# usage: convert.rb en.yml en.coffee
# -- Andrew Mao

if ARGV.length > 1 
  coffee_script_file = File.open(ARGV[1], 'w')
  proc = Proc.new do |output| 
    coffee_script_file.puts output
  end
  HashToCS.convert(YAML::load(File.open(ARGV[0])), 0, proc)
else
  HashToCS.convert(YAML::load(File.open(ARGV[0])), 0)
end


