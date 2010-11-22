# path to my git clones of the latest dm-core and extlib
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), *%w[.. lib]))

require 'pathname'
require 'rubygems'
require 'bundler/setup'

Bundler.setup(:datamapper, :runtime, :development)

# Add all external dependencies for the plugin here
# gem 'extlib', '= 1.0.2'
# require "extlib"

require 'dm-core'
require "dm-types"
require "dm-aggregates"
require "dm-migrations"
require 'dm-is-friendly'

DataMapper::Logger.new("test.log", :debug)
# DataMapper.logger.auto_flush = true

def load_driver(name, default_uri)
  return false unless DRIVERS[name]
  
  begin
    DataMapper.setup(name, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
    DataMapper::Repository.adapters[:default] = DataMapper::Repository.adapters[name]
    true
  rescue LoadError => e
    warn "Could not load do_#{name}: #{e}"
    false
  end
end

ENV['ADAPTERS'] ||= 'sqlite3 mysql'

DRIVERS = { 
  :sqlite  => 'sqlite3::memory:',
  :mysql    => 'mysql://datamapper:datamapper@localhost/dm_is_friendly_test',
  :postgres => 'postgres://postgres:postgres@localhost/dm_is_friendly_test'
}

ADAPTERS = ENV["ADAPTERS"].split(' ')

module SpecAdapterHelper
  def with_adapters(&block)
    ::ADAPTERS.each do |adapter|
      describe "with #{adapter} adapter" do
        before(:all) do
          load_driver(adapter.to_sym, ::DRIVERS[adapter.to_sym])
        end
        
        instance_eval(&block)
      end
    end
  end
end

RSpec.configure do |conf|
  def log(msg); DataMapper.logger.push("****** #{msg}"); end
  conf.extend(SpecAdapterHelper)
end
