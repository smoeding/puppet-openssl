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
    let(:facts) { os_facts }
    let(:params) { default_params }

    context "on #{os} with default parameters" do
      it {
        is_expected.to contain_class('openssl')
        is_expected.to contain_package('openssl')
          .with_ensure('installed')
          .with_name('openssl')
      }
    end

    context "on #{os} with one element for ca_cert" do
      let(:params) { default_params.merge(ca_certs: ['cert']) }

      it {
        case facts[:os][:family]
        when 'RedHat'
          is_expected.to contain_openssl__cert('cert').with_certtrust('true')
        when 'Debian', 'FreeBSD'
          is_expected.to contain_openssl__cert('cert').with_makehash('true')
        end
      }
    end

    context "on #{os} with two elements for ca_cert" do
      let(:params) { default_params.merge(ca_certs: ['cert', 'ca']) }

      it {
        case facts[:os][:family]
        when 'RedHat'
          is_expected.to contain_openssl__cert('cert').with_certtrust('true')
          is_expected.to contain_openssl__cert('ca').with_certtrust('true')
        when 'Debian', 'FreeBSD'
          is_expected.to contain_openssl__cert('cert').with_makehash('true')
          is_expected.to contain_openssl__cert('ca').with_makehash('true')
        end
      }
    end
  end
end
