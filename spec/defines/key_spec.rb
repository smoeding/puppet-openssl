require 'spec_helper'

describe 'openssl::key' do
  let(:pre_condition) do
    'class { "::openssl":
       default_key_dir       => "/key",
       default_cert_dir      => "/crt",
       cert_source_directory => "/foo",
       root_group            => "wheel"
     }'
  end

  let(:title) { 'key' }

  before do
    MockFunction.new('file') do |f|
      f.stubbed.with('/foo/key.key').returns("# /foo/key.key\n")
    end
  end

  on_supported_os.each do |os, facts|
    let(:facts) { facts }

    context "on #{os} with default parameters" do
      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_file('/key/key.key').
          with_ensure('file').
          with_owner('root').
          with_group('wheel').
          with_mode('0400').
          with_content("# /foo/key.key\n").
          with_backup('false').
          with_show_diff('false').
          that_requires('Package[openssl]')
      }
    end

    context "on #{os} with ensure => absent" do
      let(:params) do
        { ensure: 'absent' }
      end

      it {
        is_expected.to contain_class('openssl')
        is_expected.to contain_file('/key/key.key').with_ensure('absent')
      }
    end
  end
end
