require 'spec_helper'

describe 'openssl::cacert' do
  let(:pre_condition) do
    'class { "::openssl":
       default_key_dir       => "/key",
       default_cert_dir      => "/crt",
       cert_source_directory => "/foo",
       root_group            => "wheel"
     }'
  end

  let(:title) { 'cert' }

  before(:each) do
    # Mock the Puppet file() function
    Puppet::Parser::Functions.newfunction(:file, type: :rvalue) do |args|
      case args[0]
      when '/foo/cert.crt'
        "# /foo/cert.crt\n"
      when '/foo/cert.baz'
        "# /foo/cert.baz\n"
      when '/foo/ca.crt'
        "# /foo/ca.crt\n"
      end
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_file('/usr/local/share/ca-certificates/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")
              .that_notifies('Exec[openssl::update-ca-certificates]')

            is_expected.not_to contain_openssl_hash('/usr/local/share/ca-certificates/cert.crt')
            is_expected.not_to contain_openssl_certutil('cert')

          when 'FreeBSD'
            is_expected.to contain_file('/crt/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")

            is_expected.to contain_openssl_hash('/crt/cert.crt')
              .with_ensure('present')
              .that_requires('File[/crt/cert.crt]')

            is_expected.not_to contain_openssl_certutil('cert')

          when 'RedHat'
            is_expected.to contain_file('/crt/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")

            is_expected.to contain_openssl_certutil('cert')
              .with_ensure('present')
              .with_filename('/crt/cert.crt')
              .with_ssl_trust('C')
              .that_requires('File[/crt/cert.crt]')

            is_expected.not_to contain_openssl_hash('/crt/cert.crt')
          end
        }
      end

      context 'with cert => ca' do
        let(:params) do
          { cert: 'ca' }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_file('/usr/local/share/ca-certificates/ca.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")
              .that_notifies('Exec[openssl::update-ca-certificates]')
          when 'FreeBSD', 'RedHat'
            is_expected.to contain_file('/crt/ca.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")
          end
        }
      end

      context 'with source => ca' do
        let(:params) do
          { source: 'ca' }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_file('/usr/local/share/ca-certificates/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/ca.crt\n")
              .that_notifies('Exec[openssl::update-ca-certificates]')
          when 'FreeBSD', 'RedHat'
            is_expected.to contain_file('/crt/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/ca.crt\n")
          end
        }
      end

      context 'with extension => pem' do
        let(:params) do
          { extension: 'pem' }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_file('/usr/local/share/ca-certificates/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")
              .that_notifies('Exec[openssl::update-ca-certificates]')
          when 'FreeBSD', 'RedHat'
            is_expected.to contain_file('/crt/cert.pem')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")
          end
        }
      end

      context 'with source_extension => baz' do
        let(:params) do
          { source_extension: 'baz' }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_file('/usr/local/share/ca-certificates/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.baz\n")
              .that_notifies('Exec[openssl::update-ca-certificates]')
          when 'FreeBSD', 'RedHat'
            is_expected.to contain_file('/crt/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.baz\n")
          end
        }
      end

      context 'with mode => 0642' do
        let(:params) do
          { mode: '0642' }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_file('/usr/local/share/ca-certificates/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0642')
              .with_content("# /foo/cert.crt\n")
              .that_notifies('Exec[openssl::update-ca-certificates]')
          when 'FreeBSD', 'RedHat'
            is_expected.to contain_file('/crt/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0642')
              .with_content("# /foo/cert.crt\n")
          end
        }
      end

      context 'with owner => mysql' do
        let(:params) do
          { owner: 'mysql' }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_file('/usr/local/share/ca-certificates/cert.crt')
              .with_ensure('file')
              .with_owner('mysql')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")
              .that_notifies('Exec[openssl::update-ca-certificates]')
          when 'FreeBSD', 'RedHat'
            is_expected.to contain_file('/crt/cert.crt')
              .with_ensure('file')
              .with_owner('mysql')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")
          end
        }
      end

      context 'with group => mysql' do
        let(:params) do
          { group: 'mysql' }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_file('/usr/local/share/ca-certificates/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('mysql')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")
              .that_notifies('Exec[openssl::update-ca-certificates]')
          when 'FreeBSD', 'RedHat'
            is_expected.to contain_file('/crt/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('mysql')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")
          end
        }
      end

      context 'with cert_dir => /baz' do
        let(:params) do
          { cert_dir: '/baz' }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_file('/usr/local/share/ca-certificates/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")
              .that_notifies('Exec[openssl::update-ca-certificates]')
          when 'FreeBSD', 'RedHat'
            is_expected.to contain_file('/baz/cert.crt')
              .with_ensure('file')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_content("# /foo/cert.crt\n")
          end
        }
      end

      context 'with ensure => absent' do
        let(:params) do
          { ensure: 'absent' }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_file('/usr/local/share/ca-certificates/cert.crt')
              .with_ensure('absent')
              .that_notifies('Exec[openssl::update-ca-certificates]')

          when 'FreeBSD'
            is_expected.to contain_file('/crt/cert.crt')
              .with_ensure('absent')

            is_expected.to contain_openssl_hash('/crt/cert.crt')
              .with_ensure('absent')
              .that_comes_before('File[/crt/cert.crt]')

          when 'RedHat'
            is_expected.to contain_file('/crt/cert.crt')
              .with_ensure('absent')

            is_expected.to contain_openssl_certutil('cert')
              .with_ensure('absent')
              .that_comes_before('File[/crt/cert.crt]')

          end
        }
      end
    end
  end
end
