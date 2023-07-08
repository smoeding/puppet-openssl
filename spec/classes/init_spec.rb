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
        }

        case facts[:os]['family']
        when 'Debian'
          it {
            is_expected.to contain_exec('openssl::update-ca-certificates')
              .with_command('update-ca-certificates')
              .with_user('root')
              .with_refreshonly(true)

            is_expected.not_to contain_exec('openssl::update-ca-trust')
          }
        when 'RedHat'
          it {
            is_expected.to contain_exec('openssl::update-ca-trust')
              .with_command('update-ca-trust extract')
              .with_user('root')
              .with_refreshonly(true)

            is_expected.not_to contain_exec('openssl::update-ca-certificates')
          }
        else
          it {
            is_expected.not_to contain_exec('openssl::update-ca-certificates')
            is_expected.not_to contain_exec('openssl::update-ca-trust')
          }
        end
      end

      context 'with one element for ca_cert' do
        let(:params) { default_params.merge(ca_certs: ['cert']) }

        it {
          is_expected.to contain_openssl__cacert('cert')
        }

        case facts[:os]['family']
        when 'Debian'
          it {
            is_expected.to contain_file('/usr/local/share/ca-certificates/cert.crt')
          }
        when 'RedHat'
          it {
            is_expected.to contain_file('/etc/pki/ca-trust/source/anchors/cert.crt')
          }
        when 'FreeBSD'
          it {
            is_expected.to contain_file('/usr/local/etc/ssl/cert.crt')
          }
        end
      end

      context 'with two elements for ca_cert' do
        let(:params) { default_params.merge(ca_certs: ['cert', 'ca']) }

        it {
          is_expected.to contain_openssl__cacert('cert')
          is_expected.to contain_openssl__cacert('ca')
        }

        case facts[:os]['family']
        when 'Debian'
          it {
            is_expected.to contain_file('/usr/local/share/ca-certificates/cert.crt')
            is_expected.to contain_file('/usr/local/share/ca-certificates/ca.crt')
          }
        when 'RedHat'
          it {
            is_expected.to contain_file('/etc/pki/ca-trust/source/anchors/cert.crt')
            is_expected.to contain_file('/etc/pki/ca-trust/source/anchors/ca.crt')

            is_expected.to contain_openssl_certutil('cert')
            is_expected.to contain_openssl_certutil('ca')
          }
        when 'FreeBSD'
          it {
            is_expected.to contain_file('/usr/local/etc/ssl/cert.crt')
            is_expected.to contain_file('/usr/local/etc/ssl/ca.crt')

            is_expected.to contain_openssl_hash('/usr/local/etc/ssl/cert.crt')
            is_expected.to contain_openssl_hash('/usr/local/etc/ssl/ca.crt')
          }
        end
      end
    end
  end
end
