require 'rubygems'
require 'rake'
require File.join(File.dirname(__FILE__), *%w[lib is version])

version = DataMapper::Is::Friendly::VERSION

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "dm-is-friendly"
    gem.summary = %Q{DataMapper plugin that adds self-referential friendship functionality to your models.}
    gem.email = "manbehindtheman@kabari.name"
    gem.homepage = "http://github.com/kabari/dm-is-friendly"
    gem.authors = ["Kabari Hendrick"]
    gem.add_dependency("extlib", "~> #{version}")
    gem.add_dependency("dm-core", "~> #{version}")
    gem.add_dependency("dm-aggregates", "~> #{version}")
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


task :default => :spec

require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "dm-is-friendly #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

