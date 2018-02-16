require 'rspec-puppet'
require 'puppetlabs_spec_helper/module_spec_helper'

require 'rspec-puppet-facts'
include RspecPuppetFacts

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.manifest = File.join(fixture_path, '../../manifests/site.pp')
  c.hiera_config = File.join(fixture_path, '../fixtures/hiera.yaml')

  # :id and :osfamily facts are needed for concat module
  c.default_facts = {
    :hostname        => 'foo',
    :domain          => 'example.com',
    :fqdn            => 'foo.example.com',
    :id              => 'stm',
    :osfamily        => 'Debian',
    :operatingsystem => 'Debian',
    :concat_basedir  => '/var/tmp',
  }

  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
