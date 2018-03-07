require 'spec_helper'

describe 'openssl::dhparam' do
  let(:pre_condition) do
    'class { "::openssl":
       default_key_dir       => "/key",
       default_cert_dir      => "/crt",
       cert_source_directory => "/foo/bar",
       root_group            => "wheel"
     }'
  end

  let(:title) { '/foo/bar/dhparam.pem' }

  on_supported_os.each do |os, facts|
    let(:facts) { facts }

    context "on #{os} with default parameters" do
      it {
        is_expected.to contain_class('openssl')
        is_expected.
          to contain_exec('openssl dhparam -out /foo/bar/dhparam.pem -2 2048').
            with_creates('/foo/bar/dhparam.pem').
            with_timeout('1800').
            that_requires('Package[openssl]').
            that_comes_before('File[/foo/bar/dhparam.pem]')
      }
    end
  end
end
