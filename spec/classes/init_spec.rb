require 'spec_helper'

describe 'openssl' do
  let :default_params do
    {
      default_key_dir:       '/key',
      default_cert_dir:      '/crt',
      cert_source_directory: '/foo',
      root_group:            'wheel',
    }
  end

  before(:each) do
    MockFunction.new('file') do |f|
      f.stubbed.with('/foo/cert.crt').returns("# /foo/cert.crt\n")
      f.stubbed.with('/foo/ca.crt').returns("# /foo/ca.crt\n")
    end
  end

  on_supported_os.each do |os, facts|
    let(:facts) { facts }
    let(:params) { default_params }

    context "on #{os} with default parameters" do
      it {
        is_expected.to contain_class('openssl')
        is_expected.to contain_package('openssl')
          .with_ensure('installed')
          .with_name('openssl')
      }
    end

    context "on #{os} with one element for ca_cert" do
      let(:params) { default_params.merge(ca_certs: ['cert']) }

      it {
        is_expected.to contain_openssl__cert('cert').with_makehash('true')
      }
    end

    context "on #{os} with two elements for ca_cert" do
      let(:params) { default_params.merge(ca_certs: ['cert', 'ca']) }

      it {
        is_expected.to contain_openssl__cert('cert').with_makehash('true')
        is_expected.to contain_openssl__cert('ca').with_makehash('true')
      }
    end
  end
end
