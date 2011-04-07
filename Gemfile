# A sample Gemfile
source "http://rubygems.org"

DATAMAPPER = 'git://github.com/datamapper'
DM_VERSION = '~> 1.1.0'

group :runtime do # Runtime dependencies (as in the gemspec)

  if ENV['EXTLIB']
    gem 'extlib',        '~> 0.9.15', :git => "#{DATAMAPPER}/extlib.git"
  else
    gem 'activesupport', '~> 3.0.0',  :git => 'git://github.com/rails/rails.git', :branch => '3-0-stable', :require => nil
  end

  gem 'dm-core',         DM_VERSION, :git => "#{DATAMAPPER}/dm-core.git"
end

group(:development) do # Development dependencies (as in the gemspec)

  gem 'rake',           '~> 0.8.7'
  gem 'rspec',          '~> 2.1.0'
  gem 'jeweler',        '~> 1.4'
  gem 'dm-aggregates',   DM_VERSION , :git => "#{DATAMAPPER}/dm-aggregates.git"
  gem "dm-types",        DM_VERSION , :git => "#{DATAMAPPER}/dm-types.git"
end

group :quality do # These gems contain rake tasks that check the quality of the source code

  gem 'metric_fu',      '~> 1.3'
  gem 'rcov',           '~> 0.9.8'
  gem 'reek',           '~> 1.2.8'
  gem 'roodi',          '~> 2.1'
  gem 'yard',           '~> 0.5'
  gem 'yardstick',      '~> 0.1'

end

group :datamapper do # We need this because we want to pin these dependencies to their git master sources

  adapters = ENV['ADAPTER'] || ENV['ADAPTERS']
  adapters = adapters.to_s.tr(',', ' ').split.uniq - %w[ in_memory ]

  DO_VERSION     = '~> 0.10.2'
  DM_DO_ADAPTERS = %w[mysql sqlite postgres]

  if (do_adapters = DM_DO_ADAPTERS & adapters).any?
    options = {}
    options[:git] = "#{DATAMAPPER}/do.git" if ENV['DO_GIT'] == 'true'

    gem 'data_objects',  DO_VERSION, options.dup

    do_adapters.each do |adapter|
      adapter = 'sqlite3' if adapter == 'sqlite'
      gem "do_#{adapter}", DO_VERSION, options.dup
    end

    gem 'dm-do-adapter', DM_VERSION, :git => "#{DATAMAPPER}/dm-do-adapter.git"
  end

  adapters.each do |adapter|
    gem "dm-#{adapter}-adapter", DM_VERSION, :git => "#{DATAMAPPER}/dm-#{adapter}-adapter.git"
  end

  plugins = ENV['PLUGINS'] || ENV['PLUGIN']
  plugins = plugins.to_s.tr(',', ' ').split.push('dm-migrations').uniq

  plugins.each do |plugin|
    gem plugin, DM_VERSION, :git => "#{DATAMAPPER}/#{plugin}.git"
  end

end
