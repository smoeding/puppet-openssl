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

  on_supported_os.each do |os, facts|
    let(:facts) { facts }
  end

end
