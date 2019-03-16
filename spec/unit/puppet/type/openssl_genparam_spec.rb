# coding: utf-8
require 'spec_helper'

describe Puppet::Type.type(:openssl_genparam) do
  let :tmp_file do
    if Puppet::Util::Platform.windows?
      'C:\tmp\path'
    else
      '/tmp/path'
    end
  end
  let :openssl_genparam do
    Puppet::Type.type(:openssl_genparam).new(name: 'foo', file: tmp_file)
  end

  it 'defaults to ensure => present' do
    expect(openssl_genparam[:ensure]).to eq :present
  end

  it 'accepts algorithm DH' do
    openssl_genparam[:algorithm] = 'DH'
    expect(openssl_genparam[:algorithm]).to eq('DH')
  end

  it 'accepts algorithm EC' do
    openssl_genparam[:algorithm] = 'EC'
    expect(openssl_genparam[:algorithm]).to eq('EC')
  end

  it 'accepts bits 2048' do
    openssl_genparam[:bits] = '2048'
    expect(openssl_genparam[:bits]).to eq('2048')
  end

  it 'accepts bits 4096' do
    openssl_genparam[:bits] = '4096'
    expect(openssl_genparam[:bits]).to eq('4096')
  end

  it 'accepts bits 8192' do
    openssl_genparam[:bits] = '8192'
    expect(openssl_genparam[:bits]).to eq('8192')
  end

  it 'does not accept bits 512' do
    expect {
      openssl_genparam[:bits] = '512'
    }.to raise_error(Puppet::Error, %r{Invalid value "512"})
  end

  it 'accepts generator 2' do
    openssl_genparam[:generator] = '2'
    expect(openssl_genparam[:generator]).to eq('2')
  end

  it 'accepts generator 5' do
    openssl_genparam[:generator] = '5'
    expect(openssl_genparam[:generator]).to eq('5')
  end

  it 'does not accept generator 9' do
    expect {
      openssl_genparam[:generator] = '9'
    }.to raise_error(Puppet::Error, %r{Invalid value "9"})
  end

  it 'accepts curve secp521r1' do
    openssl_genparam[:curve] = 'secp521r1'
    expect(openssl_genparam[:curve]).to eq('secp521r1')
  end

  it 'does not accept curve föö' do
    expect {
      openssl_genparam[:curve] = 'föö'
    }.to raise_error(Puppet::Error, %r{Invalid value "föö"})
  end

  it 'accepts refresh_interval 42' do
    openssl_genparam[:refresh_interval] = '42'
    expect(openssl_genparam[:refresh_interval]).to eq(42)
  end

  it 'accepts refresh_interval 42s' do
    openssl_genparam[:refresh_interval] = '42s'
    expect(openssl_genparam[:refresh_interval]).to eq(42)
  end

  it 'accepts refresh_interval 42mi' do
    openssl_genparam[:refresh_interval] = '42mi'
    expect(openssl_genparam[:refresh_interval]).to eq(2520)
  end

  it 'accepts refresh_interval 42h' do
    openssl_genparam[:refresh_interval] = '42h'
    expect(openssl_genparam[:refresh_interval]).to eq(151200)
  end

  it 'accepts refresh_interval 42w' do
    openssl_genparam[:refresh_interval] = '42w'
    expect(openssl_genparam[:refresh_interval]).to eq(25401600)
  end

  it 'accepts refresh_interval 42mo' do
    openssl_genparam[:refresh_interval] = '42mo'
    expect(openssl_genparam[:refresh_interval]).to eq(108864000)
  end

  it 'accepts refresh_interval 42y' do
    openssl_genparam[:refresh_interval] = '42y'
    expect(openssl_genparam[:refresh_interval]).to eq(1324512000)
  end
end
