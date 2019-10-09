require 'spec_helper'

describe 'openssl_certutil' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:title) { 'foo' }
      let(:params) do
        { filename: '/foo.crt' }
      end

      it {
        is_expected.to be_valid_type.with_provider(:certutil)

        is_expected.to be_valid_type.with_properties('ensure')
        is_expected.to be_valid_type.with_properties('ssl_trust')
        is_expected.to be_valid_type.with_properties('email_trust')
        is_expected.to be_valid_type.with_properties('object_signing_trust')

        is_expected.to be_valid_type.with_parameters('name')
        is_expected.to be_valid_type.with_parameters('filename')
      }
    end
  end
end
