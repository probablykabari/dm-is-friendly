# A sample Gemfile
source "http://rubygems.org"

DATAMAPPER = 'git://github.com/datamapper'
DM_VERSION = '~> 1.2.0'

group :runtime do # Runtime dependencies (as in the gemspec)
  gem 'dm-core',         DM_VERSION
end

group(:development) do # Development dependencies (as in the gemspec)
  gem 'rake'
  gem 'rspec',          '~> 2.12.0'
  gem 'jeweler',        '~> 1.4'
  gem 'dm-aggregates',   DM_VERSION
  gem "dm-types",        DM_VERSION
  gem "dm-migrations",   DM_VERSION
end

group :quality do # These gems contain rake tasks that check the quality of the source code
  gem 'yard'
  gem 'yardstick'
end

group :datamapper do # We need this because we want to pin these dependencies to their git master sources

  adapters = ENV['ADAPTER'] || ENV['ADAPTERS']
  adapters = adapters.to_s.tr(',', ' ').split.uniq - %w[ in_memory ]
  adapters = nil if adapters.empty?

  DO_VERSION     = '~> 0.10.10'
  DM_DO_ADAPTERS = %w[mysql sqlite postgres]

  (adapters || DM_DO_ADAPTERS).each do |adapter|
    gem "dm-#{adapter}-adapter", DM_VERSION#, :git => "#{DATAMAPPER}/dm-#{adapter}-adapter.git"
  end

end
