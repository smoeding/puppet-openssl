require 'spec_helper'

describe 'openssl_genpkey' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:title) { '/foo.pem' }

      ['2048', '4096', '8192'].each do |bits|
        context "with algorithm => RSA, bits => #{bits}" do
          let(:params) do
            { algorithm: 'RSA', bits: bits }
          end

          it {
            is_expected.to be_valid_type.with_provider(:openssl)

            is_expected.to be_valid_type.with_properties('ensure')

            is_expected.to be_valid_type.with_parameters('file')
            is_expected.to be_valid_type.with_parameters('algorithm')
            is_expected.to be_valid_type.with_parameters('bits')
            is_expected.to be_valid_type.with_parameters('curve')
            is_expected.to be_valid_type.with_parameters('cipher')
            is_expected.to be_valid_type.with_parameters('password')
          }
        end
      end

      ['P-256', 'P-384', 'secp256k1', 'secp384r1', 'secp521r1'].each do |curve|
        context "with algorithm => EC, curve => #{curve}" do
          let(:params) do
            { algorithm: 'EC', curve: curve }
          end

          it {
            is_expected.to be_valid_type.with_provider(:openssl)

            is_expected.to be_valid_type.with_properties('ensure')

            is_expected.to be_valid_type.with_parameters('file')
            is_expected.to be_valid_type.with_parameters('algorithm')
            is_expected.to be_valid_type.with_parameters('bits')
            is_expected.to be_valid_type.with_parameters('curve')
            is_expected.to be_valid_type.with_parameters('cipher')
            is_expected.to be_valid_type.with_parameters('password')
          }
        end
      end
    end
  end
end
