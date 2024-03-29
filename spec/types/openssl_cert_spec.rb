require 'spec_helper'

describe 'openssl_cert' do
  context 'with defaults' do
    let(:title) { 'foo' }
    let(:params) do
      { path: '/foo.crt' }
    end

    it {
      is_expected.to be_valid_type.with_properties('ensure')

      is_expected.to be_valid_type.with_parameters('path')
      is_expected.to be_valid_type.with_parameters('owner')
      is_expected.to be_valid_type.with_parameters('group')
      is_expected.to be_valid_type.with_parameters('mode')
      is_expected.to be_valid_type.with_parameters('backup')
      is_expected.to be_valid_type.with_parameters('selinux_ignore_defaults')
      is_expected.to be_valid_type.with_parameters('selrange')
      is_expected.to be_valid_type.with_parameters('selrole')
      is_expected.to be_valid_type.with_parameters('seltype')
      is_expected.to be_valid_type.with_parameters('seluser')
      is_expected.to be_valid_type.with_parameters('show_diff')
      is_expected.to be_valid_type.with_parameters('request')
      is_expected.to be_valid_type.with_parameters('issuer_cert')
      is_expected.to be_valid_type.with_parameters('issuer_key')
      is_expected.to be_valid_type.with_parameters('issuer_key_password')
      is_expected.to be_valid_type.with_parameters('days')
      is_expected.to be_valid_type.with_parameters('key_usage')
      is_expected.to be_valid_type.with_parameters('key_usage_critical')
      is_expected.to be_valid_type.with_parameters('extended_key_usage')
      is_expected.to be_valid_type.with_parameters('extended_key_usage_critical')
      is_expected.to be_valid_type.with_parameters('basic_constraints_ca')
      is_expected.to be_valid_type.with_parameters('basic_constraints_ca_critical')
      is_expected.to be_valid_type.with_parameters('subject_key_identifier')
      is_expected.to be_valid_type.with_parameters('subject_key_identifier_critical')
      is_expected.to be_valid_type.with_parameters('authority_key_identifier')
      is_expected.to be_valid_type.with_parameters('signature_algorithm')
      is_expected.to be_valid_type.with_parameters('copy_request_extensions')
      is_expected.to be_valid_type.with_parameters('omit_request_extensions')
    }
  end
end
