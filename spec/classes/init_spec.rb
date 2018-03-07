require 'spec_helper'

describe 'openssl' do
  let(:params) do
    {
      :default_key_dir       => '/key',
      :default_cert_dir      => '/crt',
      :cert_source_directory => '/foo/bar',
      :root_group            => 'wheel'
    }
  end

  on_supported_os.each do |os, facts|
    let(:facts) { facts }

    context "on #{os} with default parameters" do
      it {
        is_expected.to contain_class('openssl')
        is_expected.to contain_package('openssl').
          with_ensure('installed').
          with_name('openssl')
      }
    end
  end
end
