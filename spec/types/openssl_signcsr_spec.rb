require 'spec_helper'

describe 'openssl_signcsr' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:title) { '/foo.crt' }

      it {
        is_expected.to be_valid_type.with_provider(:openssl)

        is_expected.to be_valid_type.with_properties('ensure')

        is_expected.to be_valid_type.with_parameters('file')
        is_expected.to be_valid_type.with_parameters('csr')
        is_expected.to be_valid_type.with_parameters('config')
        is_expected.to be_valid_type.with_parameters('key_file')
        is_expected.to be_valid_type.with_parameters('key_password')
        is_expected.to be_valid_type.with_parameters('days')
      }
    end
  end
end
