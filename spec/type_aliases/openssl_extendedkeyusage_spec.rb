require 'spec_helper'

describe 'Openssl::Extendedkeyusage' do
  ['serverAuth', 'clientAuth', 'codeSigning', 'emailProtection',
   'timeStamping', 'OCSPSigning', 'ipsecIKE',
   'msCodeInd', 'msCodeCom', 'msCTLSign', 'msEFS'].each do |value|
    context "can be #{value}" do
      it {
        is_expected.to allow_value(value)
      }
    end
  end
end
