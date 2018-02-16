require 'spec_helper'

describe 'openssl' do

  on_supported_os.each do |os, facts|
    let(:facts) { facts }
    let(:hiera_config) { 'hiera.yaml' }

    #hiera = Hiera.new(:config => 'hiera.yaml')

    context "on #{os} with default parameters" do
      it {
        is_expected.to contain_class('openssl')
      }
    end
  end
end
