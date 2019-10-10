require 'spec_helper'

describe 'openssl_genparam' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:title) { '/foo.pem' }

      ['2048', '4096', '8192'].each do |bits|
        ['2', '5'].each do |generator|
          context "with algorithm => DH, bits => #{bits}, generator => #{generator}" do
            let(:params) do
              { algorithm: 'DH', bits: bits, generator: generator }
            end

            it {
              is_expected.to be_valid_type.with_provider(:openssl)

              is_expected.to be_valid_type.with_properties('ensure')

              is_expected.to be_valid_type.with_parameters('file')
              is_expected.to be_valid_type.with_parameters('algorithm')
              is_expected.to be_valid_type.with_parameters('bits')
              is_expected.to be_valid_type.with_parameters('generator')
              is_expected.to be_valid_type.with_parameters('curve')
              is_expected.to be_valid_type.with_parameters('refresh_interval')
            }
          end
        end
      end
    end
  end
end
