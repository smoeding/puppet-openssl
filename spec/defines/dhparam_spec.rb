require 'spec_helper'

describe 'openssl::dhparam' do
  let(:pre_condition) do
    'class { "::openssl":
       default_key_dir       => "/key",
       default_cert_dir      => "/crt",
       cert_source_directory => "/foo",
       root_group            => "wheel"
     }'
  end

  let(:title) { '/foo/dh.pem' }

  on_supported_os.each do |os, facts|
    let(:facts) { facts }

    context "on #{os} with default parameters" do
      it {
        is_expected.to contain_class('openssl')

        is_expected.to contain_exec('openssl dhparam -out /foo/dh.pem -2 2048').
          with_creates('/foodh.pem').
          with_timeout('1800').
          that_requires('Package[openssl]').
          that_comes_before('File[/foo/dh.pem]')

        is_expected.to contain_file('/foo/dh.pem').
          with_ensure('file').
          with_owner('root').
          with_group('wheel').
          with_mode('0644')
      }
    end
  end
end
