require 'spec_helper'

describe 'openssl_selfsign' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:title) { '/foo.crt' }

      context 'creating a self-signed certificate' do
        let(:params) do
          { csr: '/foo.csr', signkey: '/tmp/foo.key' }
        end

        it {
          is_expected.to be_valid_type.with_provider(:openssl)

          is_expected.to be_valid_type.with_properties('ensure')

          is_expected.to be_valid_type.with_parameters('file')
          is_expected.to be_valid_type.with_parameters('signkey')
          is_expected.to be_valid_type.with_parameters('password')
          is_expected.to be_valid_type.with_parameters('days')
        }
      end
    end
  end
end
