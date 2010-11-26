# path to my git clones of the latest dm-core and extlib
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), *%w[.. lib]))

require 'rubygems'
require 'bundler/setup'

Bundler.setup(:datamapper, :runtime, :development)

# Add all external dependencies for the plugin here

require 'dm-core'
require 'dm-core/spec/setup'
require "dm-core/spec/lib/adapter_helpers"
require "dm-core/spec/lib/spec_helper"
require "dm-types"
require "dm-aggregates"
require "dm-migrations"
require 'dm-is-friendly'

ENV['ADAPTERS'] ||= 'sqlite mysql postgres'
ENV['LOG'] ||= "file"


ADAPTERS = ENV["ADAPTERS"].split(' ')

DRIVERS = { 
  :sqlite  => 'sqlite3::memory:',
  :mysql    => 'mysql://datamapper:datamapper@localhost/dm_is_friendly_test',
  :postgres => 'postgres://postgres:postgres@localhost/dm_is_friendly_test'
}

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
  
  def self.extended(base)
    base.class_eval do      
      def log(msg)
        DataMapper.logger.push("****** #{msg}")
      end
    end
  end

end

RSpec.configure do |config|
  
  config.extend( DataMapper::Spec::Adapters::Helpers)
  config.extend(SpecAdapterHelper)
  
  config.after :all do
    DataMapper::Spec.cleanup_models
  end

  config.after :all do
    # global ivar cleanup
    DataMapper::Spec.remove_ivars(self, instance_variables.reject { |ivar| ivar[0, 2] == '@_' })
  end
end
