require 'spec_helper'

describe 'openssl_hash' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:title) { '/foo.crt' }

      it {
        is_expected.to be_valid_type.with_provider(:openssl)

        is_expected.to be_valid_type.with_properties('ensure')

        is_expected.to be_valid_type.with_parameters('name')
      }
    end
  end
end
