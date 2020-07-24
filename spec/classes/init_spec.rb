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

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        let(:params) { default_params }

        it {
          is_expected.to contain_class('openssl')
          is_expected.to contain_package('openssl')
            .with_ensure('installed')
            .with_name('openssl')
          is_expected.not_to contain_package('ca-certificates')
        }
      end

      context 'with one element for ca_cert' do
        let(:params) { default_params.merge(ca_certs: ['cert']) }

        it {
          is_expected.to contain_openssl__cert('cert').with_manage_trust('true')
        }
      end

      context 'with two elements for ca_cert' do
        let(:params) { default_params.merge(ca_certs: ['cert', 'ca']) }

        it {
          is_expected.to contain_openssl__cert('cert').with_manage_trust('true')
          is_expected.to contain_openssl__cert('ca').with_manage_trust('true')
        }
      end

      context 'with use_ca_certificates => true' do
        let(:params) { default_params.merge(use_ca_certificates: true) }

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_package('ca-certificates')
              .with_ensure('present')
          else
            is_expected.not_to contain_package('ca-certificates')

          end
        }
      end

      context 'with use_ca_certificates => false' do
        let(:params) { default_params.merge(use_ca_certificates: false) }

        it {
          is_expected.not_to contain_package('ca-certificates')
        }
      end
    end
  end
end
