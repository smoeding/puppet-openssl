require 'spec_helper'

describe Puppet::Type.type(:openssl_genpkey) do
  let :tmp_file do
    if Puppet::Util::Platform.windows?
      'C:\tmp\path'
    else
      '/tmp/path'
    end
  end
  let :openssl_genpkey do
    Puppet::Type.type(:openssl_genpkey)
                .new(name: tmp_file, algorithm: 'RSA', bits: '2048', generator: '2')
  end

  it 'defaults to ensure => present' do
    expect(openssl_genpkey[:ensure]).to eq :present
  end

  it 'accepts algorithm RSA' do
    openssl_genpkey[:algorithm] = 'RSA'
    expect(openssl_genpkey[:algorithm]).to eq('RSA')
  end

  it 'accepts algorithm EC' do
    openssl_genpkey[:algorithm] = 'EC'
    expect(openssl_genpkey[:algorithm]).to eq('EC')
  end

  it 'accepts bits 2048' do
    openssl_genpkey[:bits] = '2048'
    expect(openssl_genpkey[:bits]).to eq('2048')
  end

  it 'accepts bits 4096' do
    openssl_genpkey[:bits] = '4096'
    expect(openssl_genpkey[:bits]).to eq('4096')
  end

  it 'accepts bits 8192' do
    openssl_genpkey[:bits] = '8192'
    expect(openssl_genpkey[:bits]).to eq('8192')
  end

  it 'accepts generator 2' do
    openssl_genpkey[:generator] = '2'
    expect(openssl_genpkey[:generator]).to eq('2')
  end

  it 'accepts generator 5' do
    openssl_genpkey[:generator] = '5'
    expect(openssl_genpkey[:generator]).to eq('5')
  end

  it 'does not accept bits 512' do
    expect {
      openssl_genpkey[:bits] = '512'
    }.to raise_error(Puppet::Error, %r{Invalid value "512"})
  end

  it 'accepts curve secp521r1' do
    openssl_genpkey[:curve] = 'secp521r1'
    expect(openssl_genpkey[:curve]).to eq('secp521r1')
  end

  it 'does not accept curve f%o' do
    expect {
      openssl_genpkey[:curve] = 'f%o'
    }.to raise_error(Puppet::Error, %r{Invalid value "f%o"})
  end

  it 'accepts cipher aes256' do
    openssl_genpkey[:cipher] = 'aes256'
    expect(openssl_genpkey[:cipher]).to eq('aes256')
  end

  it 'accepts password' do
    openssl_genpkey[:password] = 'rosebud'
    expect(openssl_genpkey[:password]).to eq('rosebud')
  end
end
