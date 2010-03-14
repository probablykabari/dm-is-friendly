# path to my git clones of the latest dm-core and extlib
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), *%w[.. ..]))

require 'pathname'
require 'rubygems'
require 'spec'

# Add all external dependencies for the plugin here
gem 'extlib', '~>0.9.14'
require "extlib"

gem 'dm-core', '~>0.10.2'
require 'dm-core'

gem 'dm-aggregates', '~>0.10.2'
require "dm-aggregates"

require Pathname(__FILE__).dirname.expand_path.parent + 'lib/dm-is-friendly'

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
  :sqlite3  => 'sqlite3::memory:',
  :mysql    => 'mysql://root:pass@localhost/dm_is_friendly_test',
  :postgres => 'postgres://postgres@localhost/dm_is_friendly_test'
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

Spec::Runner.configure do |conf|
  def log(msg); DataMapper.logger.push("****** #{msg}"); end
  conf.extend(SpecAdapterHelper)
end
