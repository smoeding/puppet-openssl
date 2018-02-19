require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.hiera_config = 'hiera.yaml'

  # :id and :osfamily facts are needed for concat module
  # c.default_facts = {
  #   :hostname        => 'foo',
  #   :domain          => 'example.com',
  #   :fqdn            => 'foo.example.com',
  #   :id              => 'stm',
  #   :osfamily        => 'Debian',
  #   :operatingsystem => 'Debian',
  #   :concat_basedir  => '/var/tmp',
  # }

  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
