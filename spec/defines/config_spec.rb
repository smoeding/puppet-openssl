require 'spec_helper'

describe 'openssl::config' do
  let(:pre_condition) do
    'class { "::openssl":
       default_key_dir       => "/key",
       default_cert_dir      => "/crt",
       cert_source_directory => "/foo",
       root_group            => "wheel"
     }'
  end

  let(:title) { '/tmp/example.com.cnf' }

  on_supported_os.each do |os, facts|
    let(:params) do
      { common_name: 'example.com' }
    end

    context "on #{os}" do
      let(:facts) { facts }

      context 'with default parameters' do
        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_ensure('file')
            .with_owner('root')
            .with_group('wheel')
            .with_mode('0600')
            .with_content(%r{^commonName\s+=\s+"example.com"$})
        }
      end

      context 'with owner => fred' do
        let(:params) do
          super().merge(owner: 'fred')
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_owner('fred')
        }
      end

      context 'with group => fred' do
        let(:params) do
          super().merge(group: 'fred')
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_group('fred')
        }
      end

      context 'with config => /tmp/config' do
        let(:params) do
          super().merge(config: '/tmp/config')
        end

        it {
          is_expected.to contain_file('/tmp/config')
        }
      end

      context 'with common_name => example.net' do
        let(:params) do
          super().merge(common_name: 'example.net')
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^commonName\s+=\s+"example.net"$})
        }
      end

      context 'with san_dns => www.example.com' do
        let(:params) do
          super().merge(subject_alternate_names_dns: ['www.example.com'])
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^DNS.1\s+=\s+www.example.com$})
        }
      end

      context 'with san_ip => 127.0.0.1' do
        let(:params) do
          super().merge(subject_alternate_names_ip: ['127.0.0.1'])
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^IP.1\s+=\s+127.0.0.1$})
        }
      end

      context 'with key_usage => [decipherOnly]' do
        let(:params) do
          super().merge(key_usage: ['decipherOnly'])
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^keyUsage\s+=\s+decipherOnly$})
        }
      end

      context 'with key_usage => [decipherOnly,encipherOnly]' do
        let(:params) do
          super().merge(key_usage: ['decipherOnly', 'encipherOnly'])
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^keyUsage\s+=\s+decipherOnly, encipherOnly$})
        }
      end

      context 'with extendend_key_usage => [msCodeInd]' do
        let(:params) do
          super().merge(extended_key_usage: ['msCodeInd'])
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^extendedKeyUsage\s+=\s+msCodeInd$})
        }
      end

      context 'with extendend_key_usage => [msCodeInd,msCodeCom]' do
        let(:params) do
          super().merge(extended_key_usage: ['msCodeInd', 'msCodeCom'])
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^extendedKeyUsage\s+=\s+msCodeInd, msCodeCom$})
        }
      end

      context 'with basic_constraints_ca => true' do
        let(:params) do
          super().merge(basic_constraints_ca: true)
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^+basicConstraints\s+=\s+CA:true$})
        }
      end

      context 'with country_name => US' do
        let(:params) do
          super().merge(country_name: 'US')
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^countryName\s+=\s+"US"$})
        }
      end

      context 'with state_or_province_name => DC' do
        let(:params) do
          super().merge(state_or_province_name: 'DC')
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^stateOrProvinceName\s+=\s+"DC"$})
        }
      end

      context 'with locality_name => Washington' do
        let(:params) do
          super().merge(locality_name: 'Washington')
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^localityName\s+=\s+"Washington"$})
        }
      end

      context 'with postal_code => 20500' do
        let(:params) do
          super().merge(postal_code: '20500')
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^postalCode\s+=\s+"20500"$})
        }
      end

      context 'with street_address => 1600 Pennsylvania Ave NW' do
        let(:params) do
          super().merge(street_address: '1600 Pennsylvania Ave NW')
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^streetAddress\s+=\s+"1600 Pennsylvania Ave NW"$})
        }
      end

      context 'with organization_name => The White House' do
        let(:params) do
          super().merge(organization_name: 'The White House')
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^organizationName\s+=\s+"The White House"$})
        }
      end

      context 'with organization_unit_name => Oval Office' do
        let(:params) do
          super().merge(organization_unit_name: 'Oval Office')
        end

        it {
          is_expected.to contain_file('/tmp/example.com.cnf')
            .with_content(%r{^organizationalUnitName\s+=\s+"Oval Office"$})
        }
      end
    end
  end
end
