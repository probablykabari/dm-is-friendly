require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "dm-is-friendly"
    gemspec.summary = %Q{DataMapper plugin that adds self-referential friendship functionality to your models.}
    gemspec.email = "kabari@gmail.com"
    gemspec.homepage = "http://github.com/RipTheJacker/dm-is-friendly"
    gemspec.authors = ["Kabari Hendrick"]
    
    gemspec.has_rdoc    = 'yard'
    gemspec.files = Dir['Rakefile', '{lib,spec}/**/*', 'README*', 'LICENSE*', 'VERSION'] - ['spec/log/dm.log']
                      
    gemspec.add_development_dependency("rspec", "~> 2.1.0")
    gemspec.add_development_dependency("jeweler")
    gemspec.add_dependency("dm-core", "~> 1.0.2")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError => e
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
  puts "-"*40
  puts e.backtrace
end

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rcov_opts =  %[-Ilib -Ispec --exclude "spec/spec_helper.rb"]
  t.rcov_opts << %[--no-html --aggregate coverage.data]
end


task :default => :spec


Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "dm-is-friendly 1.0.2"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'reek/adapters/rake_task'

  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose       = false
    t.source_files  = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort 'Reek is not available. In order to run reek, you must: gem install reek'
  end
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb', 'README.markdown', 'LICENSE']
  end
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
