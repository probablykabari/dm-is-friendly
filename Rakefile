require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "dm-is-friendly"
    gemspec.summary = %Q{DataMapper plugin that adds self-referential friendship functionality to your models.}
    gemspec.email = "kabari@gmail.com"
    gemspec.homepage = "http://github.com/kabari/dm-is-friendly"
    gemspec.authors = ["Kabari Hendrick"]
    gemspec.add_dependency("activesupport", "~> 3.0.0")
    gemspec.add_dependency("dm-core", "~> 1.0.2")
    gemspec.add_dependency("dm-aggregates", "~> 1.0.2")
  end
  Jeweler::GemcutterTasks.new
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
  rdoc.title = "dm-is-friendly 0.10.21"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
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
