# Needed to import datamapper and other gems
require 'rubygems'
require 'pathname'

# Add all external dependencies for the plugin here
gem 'extlib', '~>0.9.14'
require "extlib"

gem 'dm-core', '~>0.10.2'
require 'dm-core'

gem 'dm-aggregates', '~>0.10.2'
require "dm-aggregates"

# Require plugin-files
require Pathname(__FILE__).dirname.expand_path / 'is' / 'friendly'

# Include the plugin in Resource
# module DataMapper
#   module Model
#     include DataMapper::Is::Friendly
#   end # module Model
# end # module DataMapper

# An alternative way to do the same thing as above:
DataMapper::Model.append_extensions(DataMapper::Is::Friendly)
