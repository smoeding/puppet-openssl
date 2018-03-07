require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
require 'rspec-puppet-utils'

include RspecPuppetFacts

RSpec.configure do |c|
  c.hiera_config = 'hiera.yaml'

  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
