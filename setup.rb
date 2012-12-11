#!env ruby

require 'ap'
require 'trollop'

require 'lib/packager.rb'


SETUP_VERSION = "0.1-0"

opts = Trollop::options do
  version   "Dot Files Setup #{SETUP_VERSION}"
  banner <<-EOS

This script setups the dot files included in this distribution

Usage:
       setup.rb [options]
where [options] are:
EOS
  
  opt :include,   "Packages to include", :short => 'i', :multi => true, :type => String, :default => nil
  opt :exclude,   "Packages to exlude",  :short => 'e', :multi => true, :type => String, :default => nil
  opt :remove,    "Packages to exlude",  :short => 'r'
  opt :list,      "Packages that can be installed",  :short => 'l' 
end

def print_packages(header, packages)
  puts header
  packages.each do |package|
    puts " |--#{package}"
  end

end

def confirm(message = "Are you sure you wish to continue")
  print "#{message} (y/N): "
  responce = gets.chomp.upcase
  return responce =~/^Y$/
end

available  = Packager.available_setups

if opts[:list]
  print_packages("Available Packages:", available)
  exit
end

unless opts[:include].empty? or opts[:exclude].empty?
  puts "Options --include (-i) and --exclude (-e) are exclusive"
  exit -1
end

available = available & opts[:include] unless opts[:include].empty?
available = available - opts[:exclude] unless opts[:exclude].empty?

if opts[:remove]
  print_packages("Removing Packages:", available)
  Packager.remove_packages(available) if confirm
  exit
end

print_packages("Installing Packages:", available)
Packager.install_packages(available) if confirm
