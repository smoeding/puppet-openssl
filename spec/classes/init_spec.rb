require 'spec_helper'

describe 'openssl' do
  let :default_params do
    { cert_source_directory: '/foo' }
  end

  before(:each) do
    # Mock the Puppet file() function
    Puppet::Parser::Functions.newfunction(:file, type: :rvalue) do |args|
      case args[0]
      when '/foo/cert.crt'
        "# /foo/cert.crt\n"
      when '/foo/ca.crt'
        "# /foo/ca.crt\n"
      end
    end
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os} with default parameters" do
      let(:facts) { os_facts }
      let(:params) { default_params }

      it {
        is_expected.to contain_class('openssl')
        is_expected.to contain_package('openssl')
          .with_ensure('installed')
          .with_name('openssl')
      }
    end

    context "on #{os} with one element for ca_cert" do
      let(:facts) { os_facts }
      let(:params) { default_params.merge(ca_certs: ['cert']) }

      it {
        is_expected.to contain_openssl__cert('cert').with_manage_trust('true')
      }
    end

    context "on #{os} with two elements for ca_cert" do
      let(:facts) { os_facts }
      let(:params) { default_params.merge(ca_certs: ['cert', 'ca']) }

      it {
        is_expected.to contain_openssl__cert('cert').with_manage_trust('true')
        is_expected.to contain_openssl__cert('ca').with_manage_trust('true')
      }
    end
  end
end
