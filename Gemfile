source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'puppet-lint',                :require => false
  gem 'puppet-syntax',              :require => false
  gem 'puppet_facts',               :require => false
  gem 'puppetlabs_spec_helper',     :require => false
  gem 'rspec-puppet',               :require => false
  gem 'rspec-puppet-facts',         :require => false
  gem 'rspec-puppet-utils',         :require => false
  gem 'rubocop', '~> 0.49.1',       :require => false
  gem 'rubocop-rspec', '~> 1.15.0', :require => false
  gem 'semantic_puppet',            :require => false
  gem 'metadata-json-lint',         :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end
