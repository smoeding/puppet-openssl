require 'spec_helper'

describe 'openssl::cert' do
  let(:pre_condition) do
    'class { "::openssl":
       default_key_dir       => "/key",
       default_cert_dir      => "/crt",
       cert_source_directory => "/foo",
       root_group            => "wheel"
     }'
  end

  let(:title) { 'cert' }

  before do
    MockFunction.new('file') do |f|
      f.stubbed.with('/foo/cert.crt').returns("# /foo/cert.crt\n")
      f.stubbed.with('/foo/ca.crt').returns("# /foo/ca.crt\n")
    end
  end

  on_supported_os.each do |os, facts|
    let(:facts) { facts }

    context "on #{os} with default parameters" do
      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_concat('/crt/cert.crt').
          with_owner('root').
          with_group('wheel').
          with_mode('0444').
          with_backup('false').
          that_requires('Package[openssl]')

        is_expected.to contain_concat__fragment('/crt/cert.crt-cert').
          with_target('/crt/cert.crt').
          with_content("# /foo/cert.crt\n").
          with_order('10')
      }
    end

    context "on #{os} with cert => ca" do
      let(:params) do
        { cert: 'ca' }
      end

      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_concat('/crt/ca.crt').
          with_owner('root').
          with_group('wheel').
          with_mode('0444').
          with_backup('false').
          that_requires('Package[openssl]')

        is_expected.to contain_concat__fragment('/crt/ca.crt-cert').
          with_target('/crt/ca.crt').
          with_content("# /foo/cert.crt\n").
          with_order('10')
      }
    end

    context "on #{os} with source => ca" do
      let(:params) do
        { source: 'ca' }
      end

      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_concat('/crt/cert.crt').
          with_owner('root').
          with_group('wheel').
          with_mode('0444').
          with_backup('false').
          that_requires('Package[openssl]')

        is_expected.to contain_concat__fragment('/crt/cert.crt-cert').
          with_target('/crt/cert.crt').
          with_content("# /foo/ca.crt\n").
          with_order('10')
      }
    end

    context "on #{os} with cert_chain => [ ca ]" do
      let(:params) do
        { cert_chain: ['ca'] }
      end

      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_concat('/crt/cert.crt').
          with_owner('root').
          with_group('wheel').
          with_mode('0444').
          with_backup('false').
          that_requires('Package[openssl]')

        is_expected.to contain_concat__fragment('/crt/cert.crt-cert').
          with_target('/crt/cert.crt').
          with_content("# /foo/cert.crt\n").
          with_order('10')

        is_expected.to contain_concat__fragment('/crt/cert.crt-20').
          with_target('/crt/cert.crt').
          with_content("# /foo/ca.crt\n").
          with_order('20')
      }
    end

    context "on #{os} with extension => pem" do
      let(:params) do
        { extension: 'pem' }
      end

      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_concat('/crt/cert.pem').
          with_owner('root').
          with_group('wheel').
          with_mode('0444').
          with_backup('false').
          that_requires('Package[openssl]')

        is_expected.to contain_concat__fragment('/crt/cert.pem-cert').
          with_target('/crt/cert.pem').
          with_content("# /foo/cert.crt\n").
          with_order('10')
      }
    end

    context "on #{os} with makehash => true" do
      let(:params) do
        { makehash: true }
      end

      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_concat('/crt/cert.crt').
          with_owner('root').
          with_group('wheel').
          with_mode('0444').
          with_backup('false').
          that_requires('Package[openssl]')

        is_expected.to contain_concat__fragment('/crt/cert.crt-cert').
          with_target('/crt/cert.crt').
          with_content("# /foo/cert.crt\n").
          with_order('10')

        is_expected.to contain_exec('openssl rehash /crt/cert.crt').
          with_command('ln -s -f /crt/cert.crt `openssl x509 -hash -noout -in /crt/cert.crt`.0').
          with_provider('shell').
          with_cwd('/').
          with_logoutput('false').
          with_refreshonly('true').
          that_subscribes_to('Concat[/crt/cert.crt]')
      }
    end

    context "on #{os} with cert_mode => 0642" do
      let(:params) do
        { cert_mode: '0642' }
      end

      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_concat('/crt/cert.crt').
          with_owner('root').
          with_group('wheel').
          with_mode('0642').
          with_backup('false').
          that_requires('Package[openssl]')

        is_expected.to contain_concat__fragment('/crt/cert.crt-cert').
          with_target('/crt/cert.crt').
          with_content("# /foo/cert.crt\n").
          with_order('10')
      }
    end

    context "on #{os} with cert_owner => mysql" do
      let(:params) do
        { cert_owner: 'mysql' }
      end

      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_concat('/crt/cert.crt').
          with_owner('mysql').
          with_group('wheel').
          with_mode('0444').
          with_backup('false').
          that_requires('Package[openssl]')

        is_expected.to contain_concat__fragment('/crt/cert.crt-cert').
          with_target('/crt/cert.crt').
          with_content("# /foo/cert.crt\n").
          with_order('10')
      }
    end

    context "on #{os} with cert_group => mysql" do
      let(:params) do
        { cert_group: 'mysql' }
      end

      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_concat('/crt/cert.crt').
          with_owner('root').
          with_group('mysql').
          with_mode('0444').
          with_backup('false').
          that_requires('Package[openssl]')

        is_expected.to contain_concat__fragment('/crt/cert.crt-cert').
          with_target('/crt/cert.crt').
          with_content("# /foo/cert.crt\n").
          with_order('10')
      }
    end

    context "on #{os} with cert_dir => /baz" do
      let(:params) do
        { cert_dir: '/baz' }
      end

      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_concat('/baz/cert.crt').
          with_owner('root').
          with_group('wheel').
          with_mode('0444').
          with_backup('false').
          that_requires('Package[openssl]')

        is_expected.to contain_concat__fragment('/baz/cert.crt-cert').
          with_target('/baz/cert.crt').
          with_content("# /foo/cert.crt\n").
          with_order('10')
      }
    end

    context "on #{os} with cert_file => /baz/ca.pem" do
      let(:params) do
        { cert_file: '/baz/ca.pem' }
      end

      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_concat('/baz/ca.pem').
          with_owner('root').
          with_group('wheel').
          with_mode('0444').
          with_backup('false').
          that_requires('Package[openssl]')

        is_expected.to contain_concat__fragment('/baz/ca.pem-cert').
          with_target('/baz/ca.pem').
          with_content("# /foo/cert.crt\n").
          with_order('10')
      }
    end

    context "on #{os} with ensure => absent" do
      let(:params) do
        { ensure: 'absent' }
      end

      it {
        is_expected.to contain_class('openssl')
        is_expected.to contain_file('/crt/cert.crt').with_ensure('absent')
      }
    end
  end
end
