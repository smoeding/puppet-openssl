# @summary Valid parameter values for the OpenSSL keyusage
type Openssl::Keyusage = Enum[
  'digitalSignature', 'nonRepudiation',
  'keyEncipherment', 'dataEncipherment',
  'keyAgreement', 'keyCertSign',
  'cRLSign', 'encipherOnly', 'decipherOnly'
]
