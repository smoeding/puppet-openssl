require 'spec_helper'

describe 'openssl::cert' do
  let(:pre_condition) do
    'class { "::openssl":
       default_key_dir       => "/key",
       default_cert_dir      => "/crt",
       cert_source_directory => "/foo",
       root_group            => "wheel",
       use_ca_certificates   => false
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
          is_expected.to contain_concat('/crt/cert.crt')
            .with_owner('root')
            .with_group('wheel')
            .with_mode('0444')
            .with_backup(false)
            .with_show_diff(false)
            .with_ensure_newline(true)

          is_expected.to contain_concat__fragment('/crt/cert.crt-cert')
            .with_target('/crt/cert.crt')
            .with_content("# /foo/cert.crt\n")
            .with_order('10')

          is_expected.not_to contain_openssl_hash('/crt/cert.crt')
          is_expected.not_to contain_openssl_certutil('cert')
        }
      end

      context 'with cert => ca' do
        let(:params) do
          { cert: 'ca' }
        end

        it {
          is_expected.to contain_concat('/crt/ca.crt')
            .with_owner('root')
            .with_group('wheel')
            .with_mode('0444')
            .with_backup(false)
            .with_show_diff(false)
            .with_ensure_newline(true)

          is_expected.to contain_concat__fragment('/crt/ca.crt-cert')
            .with_target('/crt/ca.crt')
            .with_content("# /foo/cert.crt\n")
            .with_order('10')
        }
      end

      context 'with source => ca' do
        let(:params) do
          { source: 'ca' }
        end

        it {
          is_expected.to contain_concat('/crt/cert.crt')
            .with_owner('root')
            .with_group('wheel')
            .with_mode('0444')
            .with_backup(false)
            .with_show_diff(false)
            .with_ensure_newline(true)

          is_expected.to contain_concat__fragment('/crt/cert.crt-cert')
            .with_target('/crt/cert.crt')
            .with_content("# /foo/ca.crt\n")
            .with_order('10')
        }
      end

      context 'with cert_chain => [ ca ]' do
        let(:params) do
          { cert_chain: ['ca'] }
        end

        it {
          is_expected.to contain_concat('/crt/cert.crt')
            .with_owner('root')
            .with_group('wheel')
            .with_mode('0444')
            .with_backup(false)
            .with_show_diff(false)
            .with_ensure_newline(true)

          is_expected.to contain_concat__fragment('/crt/cert.crt-cert')
            .with_target('/crt/cert.crt')
            .with_content("# /foo/cert.crt\n")
            .with_order('10')

          is_expected.to contain_concat__fragment('/crt/cert.crt-20')
            .with_target('/crt/cert.crt')
            .with_content("# /foo/ca.crt\n")
            .with_order('20')
        }
      end

      context 'with extension => pem' do
        let(:params) do
          { extension: 'pem' }
        end

        it {
          is_expected.to contain_concat('/crt/cert.pem')
            .with_owner('root')
            .with_group('wheel')
            .with_mode('0444')
            .with_backup(false)
            .with_show_diff(false)
            .with_ensure_newline(true)

          is_expected.to contain_concat__fragment('/crt/cert.pem-cert')
            .with_target('/crt/cert.pem')
            .with_content("# /foo/cert.crt\n")
            .with_order('10')
        }
      end

      context 'with source_extension => baz' do
        let(:params) do
          { source_extension: 'baz' }
        end

        it {
          is_expected.to contain_concat('/crt/cert.crt')
            .with_owner('root')
            .with_group('wheel')
            .with_mode('0444')
            .with_backup(false)
            .with_show_diff(false)
            .with_ensure_newline(true)

          is_expected.to contain_concat__fragment('/crt/cert.crt-cert')
            .with_target('/crt/cert.crt')
            .with_content("# /foo/cert.baz\n")
            .with_order('10')
        }
      end

      context 'with manage_trust => true and cert_chain' do
        let(:params) do
          { manage_trust: true, cert_chain: ['ca'] }
        end

        it {
          is_expected.to compile.and_raise_error(%r{cert_chain must be empty if manage_trust is true})
        }
      end

      context 'with manage_trust => true' do
        let(:params) do
          { manage_trust: true }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_concat('/crt/cert.crt')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_backup(false)
              .with_show_diff(false)
              .with_ensure_newline(true)

            is_expected.to contain_concat__fragment('/crt/cert.crt-cert')
              .with_target('/crt/cert.crt')
              .with_content("# /foo/cert.crt\n")
              .with_order('10')

            is_expected.to contain_openssl_hash('/crt/cert.crt')
              .with_ensure('present')
              .that_requires('Concat[/crt/cert.crt]')

            is_expected.not_to contain_openssl_certutil('cert')
          when 'FreeBSD'
            is_expected.to contain_concat('/crt/cert.crt')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_backup(false)
              .with_show_diff(false)
              .with_ensure_newline(true)

            is_expected.to contain_concat__fragment('/crt/cert.crt-cert')
              .with_target('/crt/cert.crt')
              .with_content("# /foo/cert.crt\n")
              .with_order('10')

            is_expected.to contain_openssl_hash('/crt/cert.crt')
              .with_ensure('present')
              .that_requires('Concat[/crt/cert.crt]')

            is_expected.not_to contain_openssl_certutil('cert')
          when 'RedHat'
            is_expected.to contain_concat('/crt/cert.crt')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_backup(false)
              .with_show_diff(false)
              .with_ensure_newline(true)

            is_expected.to contain_concat__fragment('/crt/cert.crt-cert')
              .with_target('/crt/cert.crt')
              .with_content("# /foo/cert.crt\n")
              .with_order('10')

            is_expected.to contain_openssl_certutil('cert')
              .with_ensure('present')
              .with_filename('/crt/cert.crt')
              .with_ssl_trust('C')
              .that_requires('Concat[/crt/cert.crt]')

            is_expected.not_to contain_openssl_hash('/crt/cert.crt')
          end
        }
      end

      context 'with manage_trust => true, use_ca_certificates => true' do
        let(:pre_condition) do
          'class { "::openssl":
             default_key_dir       => "/key",
             default_cert_dir      => "/crt",
             cert_source_directory => "/foo",
             root_group            => "wheel",
             use_ca_certificates   => true
           }'
        end
        let(:params) do
          { manage_trust: true }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_concat('/usr/local/share/ca-certificates/cert.crt')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_backup(false)
              .with_show_diff(false)
              .with_ensure_newline(true)
              .that_notifies('Exec[openssl::update-ca-certificates]')

            is_expected.to contain_concat__fragment('/usr/local/share/ca-certificates/cert.crt-cert')
              .with_target('/usr/local/share/ca-certificates/cert.crt')
              .with_content("# /foo/cert.crt\n")
              .with_order('10')

            is_expected.not_to contain_openssl_hash('/crt/cert.crt')
            is_expected.not_to contain_openssl_certutil('cert')
          when 'FreeBSD'
            is_expected.to contain_concat('/crt/cert.crt')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_backup(false)
              .with_show_diff(false)
              .with_ensure_newline(true)

            is_expected.to contain_concat__fragment('/crt/cert.crt-cert')
              .with_target('/crt/cert.crt')
              .with_content("# /foo/cert.crt\n")
              .with_order('10')

            is_expected.to contain_openssl_hash('/crt/cert.crt')
              .with_ensure('present')
              .that_requires('Concat[/crt/cert.crt]')

            is_expected.not_to contain_openssl_certutil('cert')
          when 'RedHat'
            is_expected.to contain_concat('/crt/cert.crt')
              .with_owner('root')
              .with_group('wheel')
              .with_mode('0444')
              .with_backup(false)
              .with_show_diff(false)
              .with_ensure_newline(true)

            is_expected.to contain_concat__fragment('/crt/cert.crt-cert')
              .with_target('/crt/cert.crt')
              .with_content("# /foo/cert.crt\n")
              .with_order('10')

            is_expected.to contain_openssl_certutil('cert')
              .with_ensure('present')
              .with_filename('/crt/cert.crt')
              .with_ssl_trust('C')
              .that_requires('Concat[/crt/cert.crt]')

            is_expected.not_to contain_openssl_hash('/crt/cert.crt')
          end
        }
      end

      context 'with mode => 0642' do
        let(:params) do
          { mode: '0642' }
        end

        it {
          is_expected.to contain_concat('/crt/cert.crt')
            .with_owner('root')
            .with_group('wheel')
            .with_mode('0642')
            .with_backup(false)
            .with_show_diff(false)
            .with_ensure_newline(true)

          is_expected.to contain_concat__fragment('/crt/cert.crt-cert')
            .with_target('/crt/cert.crt')
            .with_content("# /foo/cert.crt\n")
            .with_order('10')
        }
      end

      context 'with owner => mysql' do
        let(:params) do
          { owner: 'mysql' }
        end

        it {
          is_expected.to contain_concat('/crt/cert.crt')
            .with_owner('mysql')
            .with_group('wheel')
            .with_mode('0444')
            .with_backup(false)
            .with_show_diff(false)
            .with_ensure_newline(true)

          is_expected.to contain_concat__fragment('/crt/cert.crt-cert')
            .with_target('/crt/cert.crt')
            .with_content("# /foo/cert.crt\n")
            .with_order('10')
        }
      end

      context 'with group => mysql' do
        let(:params) do
          { group: 'mysql' }
        end

        it {
          is_expected.to contain_concat('/crt/cert.crt')
            .with_owner('root')
            .with_group('mysql')
            .with_mode('0444')
            .with_backup(false)
            .with_show_diff(false)
            .with_ensure_newline(true)

          is_expected.to contain_concat__fragment('/crt/cert.crt-cert')
            .with_target('/crt/cert.crt')
            .with_content("# /foo/cert.crt\n")
            .with_order('10')
        }
      end

      context 'with cert_dir => /baz' do
        let(:params) do
          { cert_dir: '/baz' }
        end

        it {
          is_expected.to contain_concat('/baz/cert.crt')
            .with_owner('root')
            .with_group('wheel')
            .with_mode('0444')
            .with_backup(false)
            .with_show_diff(false)
            .with_ensure_newline(true)

          is_expected.to contain_concat__fragment('/baz/cert.crt-cert')
            .with_target('/baz/cert.crt')
            .with_content("# /foo/cert.crt\n")
            .with_order('10')
        }
      end

      context 'with ensure => absent' do
        let(:params) do
          { ensure: 'absent' }
        end

        it {
          is_expected.to contain_file('/crt/cert.crt').with_ensure('absent')
          is_expected.not_to contain_openssl_hash('/crt/cert.crt')
          is_expected.not_to contain_openssl_certutil('cert')
        }
      end

      context 'with ensure => absent, manage_trust => true' do
        let(:params) do
          { ensure: 'absent', manage_trust: true }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_file('/crt/cert.crt')
              .with_ensure('absent')

            is_expected.to contain_openssl_hash('/crt/cert.crt')
              .with_ensure('absent')
              .that_comes_before('File[/crt/cert.crt]')

          when 'FreeBSD'
            is_expected.to contain_file('/crt/cert.crt')
              .with_ensure('absent')

            is_expected.to contain_openssl_hash('/crt/cert.crt')
              .with_ensure('absent')
              .that_comes_before('File[/crt/cert.crt]')

          when 'RedHat'
            is_expected.to contain_openssl_certutil('cert')
              .with_ensure('absent')
              .that_comes_before('File[/crt/cert.crt]')
          end
        }
      end

      context 'with ensure => absent, manage_trust => true, use_ca_certificates => true' do
        let(:pre_condition) do
          'class { "::openssl":
             default_key_dir       => "/key",
             default_cert_dir      => "/crt",
             cert_source_directory => "/foo",
             root_group            => "wheel",
             use_ca_certificates   => true
           }'
        end
        let(:params) do
          { ensure: 'absent', manage_trust: true }
        end

        it {
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_file('/usr/local/share/ca-certificates/cert.crt')
              .with_ensure('absent')
              .that_notifies('Exec[openssl::update-ca-certificates]')

            is_expected.not_to contain_openssl_hash('/crt/cert.crt')

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
