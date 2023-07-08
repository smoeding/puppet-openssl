# openssl_selfsign.rb --- Create an OpenSSL self-signed certificate

Puppet::Type.newtype(:openssl_selfsign) do
  @doc = <<-DOC
    @summary Create an OpenSSL self-signed certificate

    **This type is deprecated!**

    The type takes a certificate signing request (CSR) and a key file to
    generate a self-signed certificate.

    Certificate extensions can be added by using the `extensions` and
    `extfile` parameters.

    Optionally a key password can be provided if the used key is encrypted.

    The certificate will be valid for the given number of days.

    The type is refreshable. The `openssl_selfsign` type will regenerate the
    certificate if the resource is notified from another resource.

    @example Create a self-signed certificate with extensions valid for one year

      openssl_signcsr { '/tmp/cert.crt':
        csr        => '/tmp/cert.csr',
        signkey    => '/tmp/cert.key',
        extfile    => '/tmp/cert.cnf',
        extensions => 'v3_ext',
        days       => '365',
      }
  DOC

  ensurable do
    desc <<-DOC
    The basic property that the resource should be in.
  DOC

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

  newparam(:signkey) do
    desc 'Required. The file with the OpenSSL key to use for the self-signed certificate.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:password) do
    desc <<-DOC
      The password to decrypt the key.
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
    [self[:csr], self[:extfile]]
  end

  autorequire(:openssl_genpkey) do
    [self[:signkey]]
  end

  validate do
    raise Puppet::ParseError, "Parameter 'csr' is mandatory" if self[:csr].nil?
    raise Puppet::ParseError, "Parameter 'signkey' is mandatory" if self[:signkey].nil?
  end

  def refresh
    provider.refresh if self[:ensure] == :present
  end
end
