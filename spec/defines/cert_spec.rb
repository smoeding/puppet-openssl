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

    context "on #{os} with default parameters" do
      let(:params) do
        { makehash: 'true' }
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
