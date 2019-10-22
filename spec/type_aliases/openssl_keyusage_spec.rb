require 'spec_helper'

describe 'Openssl::Keyusage' do
  ['digitalSignature', 'nonRepudiation',
   'keyEncipherment', 'dataEncipherment',
   'keyAgreement', 'keyCertSign',
   'cRLSign', 'encipherOnly', 'decipherOnly'].each do |value|
    context "can be #{value}" do
      it {
        is_expected.to allow_value(value)
      }
    end
  end
end
