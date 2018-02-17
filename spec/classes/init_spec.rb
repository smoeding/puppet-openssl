require 'spec_helper'

describe 'openssl' do
  let(:hiera_config) { 'hiera.yaml' }
  hiera = Hiera.new(:config => 'hiera.yaml')

  on_supported_os.each do |os, facts|
    let(:facts) { facts }

    context "on #{os} with default parameters" do
      let(:params) do
        { :cert_source_directory => '/foo/bar' }
      end

      it {
        is_expected.to contain_class('openssl')
      }
    end
  end
end
