require 'spec_helper'

describe 'openssl_key' do
  context 'with defaults' do
    let(:title) { 'foo' }
    let(:params) do
      { path: '/foo.key' }
    end

    it {
      is_expected.to be_valid_type.with_properties('ensure')

      is_expected.to be_valid_type.with_parameters('path')
      is_expected.to be_valid_type.with_parameters('owner')
      is_expected.to be_valid_type.with_parameters('group')
      is_expected.to be_valid_type.with_parameters('mode')
      is_expected.to be_valid_type.with_parameters('backup')
      is_expected.to be_valid_type.with_parameters('force')
      is_expected.to be_valid_type.with_parameters('selinux_ignore_defaults')
      is_expected.to be_valid_type.with_parameters('selrange')
      is_expected.to be_valid_type.with_parameters('selrole')
      is_expected.to be_valid_type.with_parameters('seltype')
      is_expected.to be_valid_type.with_parameters('seluser')
      is_expected.to be_valid_type.with_parameters('show_diff')
      is_expected.to be_valid_type.with_parameters('algorithm')
      is_expected.to be_valid_type.with_parameters('bits')
      is_expected.to be_valid_type.with_parameters('curve')
      is_expected.to be_valid_type.with_parameters('cipher')
      is_expected.to be_valid_type.with_parameters('password')
    }
  end
end
