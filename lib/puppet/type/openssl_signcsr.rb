# openssl_signcsr.rb --- Sign openssl CSR file using a CA

Puppet::Type.newtype(:openssl_signcsr) do
  @doc = <<-DOC
    @summary Sign OpenSSL certificate signing request using a CA

    **This type is still beta!**

    The name and configuration file of a CA is required.

    Certificate extensions can be added by using the `extensions` and
    `extfile` parameters.

    Optionally a key password can be provided if the used key is encrypted.

    The certificate will be valid for the given number of days.

    The type is refreshable. The `openssl_signcsr` type will regenerate the
    certificate if the resource is notified from another resource.

    @example Use a CA to sign a CSR

      openssl_signcsr { '/tmp/cert.crt':
        csr       => '/tmp/cert.csr',
        ca_name   => 'My-Root-CA',
        ca_config => '/etc/ssl/CA.cnf',
        days      => '365',
      }

    @example Regenerate a certificate if the CSR changes

      openssl_signcsr { '/tmp/cert.crt':
        csr       => '/tmp/cert.csr',
        ca_name   => 'My-Root-CA',
        ca_config => '/etc/ssl/CA.cnf',
        subscribe => File['/tmp/cert.csr'],
      }
  DOC

  ensurable do
    desc 'Specifies whether the resource should exist.'

    defaultvalues
    defaultto :present
  end

  newparam(:file, namevar: true) do
    desc 'The signed certificate file to manage.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:csr) do
    desc 'Required. The file containing the certificate signing request.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:ca_name) do
    desc 'Required. The name of the CA that is used to sign the CSR.'
  end

  newparam(:ca_config) do
    desc 'Required. The configuration file of the CA that is used to sign the CSR.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:password) do
    desc <<-DOC
      The password to decrypt the CA key.
      Leave the parameter undefined if the key is not encrypted.
    DOC

    munge { |value| value.to_s }
  end

  newparam(:days) do
    desc 'The number of days the certificate should be valid.'

    newvalues %r{^[0-9]+$}
    defaultto '370'
    munge { |value| value.to_s }
  end

  newparam(:extfile) do
    desc 'The file with the certificate extensions.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:extensions) do
    desc <<-DOC
      The section name of the extensions. The OpenSSL defaults will be used
      if the parameter is `undef`.
    DOC
  end

  autorequire(:file) do
    [self[:csr], self[:ca_config], self[:extfile]]
  end

  validate do
    raise Puppet::ParseError, "Parameter 'csr' is mandatory" if self[:csr].nil?
    raise Puppet::ParseError, "Parameter 'ca_name' is mandatory" if self[:ca_name].nil?
    raise Puppet::ParseError, "Parameter 'ca_config' is mandatory" if self[:ca_config].nil?
  end

  def refresh
    provider.refresh if self[:ensure] == :present
  end
end
