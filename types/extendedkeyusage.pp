# @summary Valid parameter values for the OpenSSL extendend key usage
type Openssl::Extendedkeyusage = Enum[
  'serverAuth', 'clientAuth', 'codeSigning', 'emailProtection',
  'timeStamping', 'OCSPSigning', 'ipsecIKE',
  'msCodeInd', 'msCodeCom', 'msCTLSign', 'msEFS',
]
