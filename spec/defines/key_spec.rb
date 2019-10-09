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

  before(:each) do
    # Mock the Puppet file() function
    Puppet::Parser::Functions.newfunction(:file, type: :rvalue) do |args|
      case args[0]
      when '/foo/key.key'
        "# /foo/key.key\n"
      when '/foo/key.baz'
        "# /foo/key.baz\n"
      when '/foo/secret.key'
        "# /foo/secret.key\n"
      end
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os} with default parameters" do
      let(:facts) { facts }

      it {
        is_expected.to contain_file('/key/key.key')
          .with_ensure('file')
          .with_owner('root')
          .with_group('wheel')
          .with_mode('0400')
          .with_content("# /foo/key.key\n")
          .with_backup(false)
          .with_show_diff(false)
      }
    end

    context "on #{os} with key => secret" do
      let(:facts) { facts }
      let(:params) do
        { key: 'secret' }
      end

      it {
        is_expected.to contain_file('/key/secret.key')
          .with_ensure('file')
          .with_owner('root')
          .with_group('wheel')
          .with_mode('0400')
          .with_content("# /foo/key.key\n")
          .with_backup(false)
          .with_show_diff(false)
      }
    end

    context "on #{os} with source => secret" do
      let(:facts) { facts }
      let(:params) do
        { source: 'secret' }
      end

      it {
        is_expected.to contain_file('/key/key.key')
          .with_ensure('file')
          .with_owner('root')
          .with_group('wheel')
          .with_mode('0400')
          .with_content("# /foo/secret.key\n")
          .with_backup(false)
          .with_show_diff(false)
      }
    end

    context "on #{os} with extension => pem" do
      let(:facts) { facts }
      let(:params) do
        { extension: 'pem' }
      end

      it {
        is_expected.to contain_file('/key/key.pem')
          .with_ensure('file')
          .with_owner('root')
          .with_group('wheel')
          .with_mode('0400')
          .with_content("# /foo/key.key\n")
          .with_backup(false)
          .with_show_diff(false)
      }
    end

    context "on #{os} with source_extension => baz" do
      let(:facts) { facts }
      let(:params) do
        { source_extension: 'baz' }
      end

      it {
        is_expected.to contain_file('/key/key.key')
          .with_ensure('file')
          .with_owner('root')
          .with_group('wheel')
          .with_mode('0400')
          .with_content("# /foo/key.baz\n")
          .with_backup(false)
          .with_show_diff(false)
      }
    end

    context "on #{os} with mode => 0642" do
      let(:facts) { facts }
      let(:params) do
        { mode: '0642' }
      end

      it {
        is_expected.to contain_file('/key/key.key')
          .with_ensure('file')
          .with_owner('root')
          .with_group('wheel')
          .with_mode('0642')
          .with_content("# /foo/key.key\n")
          .with_backup(false)
          .with_show_diff(false)
      }
    end

    context "on #{os} with owner => mysql" do
      let(:facts) { facts }
      let(:params) do
        { owner: 'mysql' }
      end

      it {
        is_expected.to contain_file('/key/key.key')
          .with_ensure('file')
          .with_owner('mysql')
          .with_group('wheel')
          .with_mode('0400')
          .with_content("# /foo/key.key\n")
          .with_backup(false)
          .with_show_diff(false)
      }
    end

    context "on #{os} with group => mysql" do
      let(:facts) { facts }
      let(:params) do
        { group: 'mysql' }
      end

      it {
        is_expected.to contain_file('/key/key.key')
          .with_ensure('file')
          .with_owner('root')
          .with_group('mysql')
          .with_mode('0400')
          .with_content("# /foo/key.key\n")
          .with_backup(false)
          .with_show_diff(false)
      }
    end

    context "on #{os} with key_dir => /baz" do
      let(:facts) { facts }
      let(:params) do
        { key_dir: '/baz' }
      end

      it {
        is_expected.to contain_file('/baz/key.key')
          .with_ensure('file')
          .with_owner('root')
          .with_group('wheel')
          .with_mode('0400')
          .with_content("# /foo/key.key\n")
          .with_backup(false)
          .with_show_diff(false)
      }
    end

    context "on #{os} with ensure => absent" do
      let(:facts) { facts }
      let(:params) do
        { ensure: 'absent' }
      end

      it {
        is_expected.to contain_file('/key/key.key').with_ensure('absent')
      }
    end
  end
end
