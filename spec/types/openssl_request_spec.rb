require 'spec_helper'

describe 'openssl_request' do
  context 'with defaults' do
    let(:title) { 'foo' }
    let(:params) do
      { path: '/foo.csr' }
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
      is_expected.to be_valid_type.with_parameters('common_name')
      is_expected.to be_valid_type.with_parameters('domain_component')
      is_expected.to be_valid_type.with_parameters('organization_unit_name')
      is_expected.to be_valid_type.with_parameters('organization_name')
      is_expected.to be_valid_type.with_parameters('locality_name')
      is_expected.to be_valid_type.with_parameters('state_or_province_name')
      is_expected.to be_valid_type.with_parameters('country_name')
      is_expected.to be_valid_type.with_parameters('email_address')
      is_expected.to be_valid_type.with_parameters('serial')
      is_expected.to be_valid_type.with_parameters('key_usage')
      is_expected.to be_valid_type.with_parameters('key_usage_critical')
      is_expected.to be_valid_type.with_parameters('extended_key_usage')
      is_expected.to be_valid_type.with_parameters('extended_key_usage_critical')
      is_expected.to be_valid_type.with_parameters('basic_constraints_ca')
      is_expected.to be_valid_type.with_parameters('basic_constraints_ca_critical')
      is_expected.to be_valid_type.with_parameters('subject_alternate_names_dns')
      is_expected.to be_valid_type.with_parameters('subject_alternate_names_ip')
      is_expected.to be_valid_type.with_parameters('key')
      is_expected.to be_valid_type.with_parameters('key_password')
      is_expected.to be_valid_type.with_parameters('signature_algorithm')
    }
  end
end
