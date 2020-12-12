source "https://rubygems.org"

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : ['>= 6.0.0', '< 7.0.0']

group :test do
  gem 'puppet', puppetversion,                require: false
  gem 'puppetlabs_spec_helper', '>= 0.1.0',   require: false
  gem 'puppet-lint', '>= 0.3.2',              require: false
  gem 'facter', '>= 3.0.0',                   require: false
  gem 'simplecov', '>= 0.11.0',               require: false
  gem 'simplecov-console',                    require: false
  gem 'rspec-puppet-facts',                   require: false
  gem 'parallel_tests',                       require: false
end