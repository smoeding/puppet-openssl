# openssl_signcsr.rb --- Sign openssl CSR files

Puppet::Type.newtype(:openssl_signcsr) do
  @doc = <<-DOC
    @summary Sign OpenSSL certificate signing request.

    **This type is still beta!**

    This type can operate in either self-signed or CA mode.

    In self-signed mode it takes a certificate signing request (CSR) and a
    key file to generate a certificate. In CA mode the name and configuration
    file of a CA is required.

    Certificate extensions can be added by using the `extensions` and
    `extfile` parameters.

    Optionally a key password can be provided if the used key is encrypted.

    The certificate will be valid for the given number of days.

    The type is refreshable. The `openssl_signcsr` type will regenerate the
    certificate if the resource is notified from another resource.

    @example Use a CA to sign a CSR

      openssl_signcert { '/tmp/cert.crt':
        csr       => '/tmp/cert.csr',
        ca_name   => 'My-Root-CA',
        ca_config => '/etc/ssl/CA.cnf',
        days      => '365',
      }

    @example Create a self-signed certificate with extensions valid for one year

      openssl_signcert { '/tmp/cert.crt':
        csr        => '/tmp/cert.csr',
        signkey    => '/tmp/cert.key',
        extfile    => '/tmp/cert.cnf',
        extensions => 'v3_ext',
        days       => '365',
      }

    @example Regenerate a certificate if the CSR changes

      openssl_signcert { '/tmp/cert.crt':
        csr       => '/tmp/cert.csr',
        signkey   => '/tmp/cert.key',
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

  newparam(:selfsigned, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'Specifies whether to create a self-signed certificate.'
    defaultto false
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
    desc <<-DOC
      The name of the CA that is used to sign the CSR.
      Mandatory if `selfsigned => false`.
    DOC
  end

  newparam(:ca_config) do
    desc <<-DOC
      The configuration file of the CA that is used to sign the CSR.
      Mandatory if `selfsigned => false`.
    DOC

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:signkey) do
    desc <<-DOC
      The file with the OpenSSL key to use for the self-signed certificate.
      Mandatory if `selfsigned => true`.
    DOC

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:password) do
    desc <<-DOC
      The password to decrypt the key. This must be the password of `signkey`
      if `selfsigned => true`. If `selfsigned => false` it must be the
      password of the CA key. Leave the parameter undefined if the key is not
      encrypted.
    DOC

    munge { |value| value.to_s }
  end

  newparam(:days) do
    desc 'The number of days the certificate should be valid.'

    newvalues %r{^[0-9]+$}
    defaultto '365'
    munge { |value| value.to_s }
  end

  newparam(:extfile) do
    desc 'The file that has the certificate extensions.'

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

  autorequire(:openssl_genpkey) do
    [self[:signkey]]
  end

  validate do
    raise Puppet::ParseError, "Parameter 'csr' is mandatory" if self[:csr].nil?

    if self[:selfsigned]
      # Check parameters for a self-signed cert
      raise Puppet::ParseError, "Can't use 'ca_name' when 'selfsigned => true'" unless self[:ca_name].nil?
      raise Puppet::ParseError, "Can't use 'ca_config' when 'selfsigned => true'" unless self[:ca_config].nil?
      raise Puppet::ParseError, "Parameter 'signkey' is mandatory when 'selfsigned => true'" if self[:signkey].nil?
    else
      # Check parameters for a CA signed cert
      raise Puppet::ParseError, "Parameter 'ca_name' is mandatory when 'selfsigned => false'" if self[:ca_name].nil?
      raise Puppet::ParseError, "Parameter 'ca_config' is mandatory when 'selfsigned => false'" if self[:ca_config].nil?
      raise Puppet::ParseError, "Can't use 'signkey' when 'selfsigned => false'" unless self[:signkey].nil?
    end
  end

  def refresh
    provider.refresh if self[:ensure] == :present
  end
end
