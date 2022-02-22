require 'spec_helper'

describe 'openssl::csr' do
  let(:pre_condition) do
    'class { "::openssl":
       default_key_dir       => "/key",
       default_cert_dir      => "/crt",
       cert_source_directory => "/foo",
       root_group            => "wheel"
     }'
  end

  let(:title) { '/tmp/example.com.csr' }

  on_supported_os.each do |os, facts|
    let(:params) do
      {
        common_name: 'example.com',
        config: '/tmp/example.com.cnf',
        key_file: '/tmp/example.com.key',
      }
    end

    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_openssl__config('/tmp/example.com.cnf')
            .with_common_name('example.com')

          is_expected.to contain_exec('openssl req -new -config /tmp/example.com.cnf -key /tmp/example.com.key -out /tmp/example.com.csr')
            .with_creates('/tmp/example.com.csr')
            .that_requires('File[/tmp/example.com.cnf]')
            .that_comes_before('File[/tmp/example.com.csr]')

          is_expected.to contain_file('/tmp/example.com.csr')
            .with_ensure('file')
            .with_owner('root')
            .with_group('wheel')
            .with_mode('0444')
        }
      end
    end
  end
end
