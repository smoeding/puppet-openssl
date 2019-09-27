# openssl_trustcert.rb --- Install certificate as trusted

Puppet::Type.newtype(:openssl_trustcert) do
  desc <<-DOC
    @summary Install a certificate file as trusted certificate

    The certificate file is installed as a trusted certificate if
    'ensure => present'. If 'ensure => absent' the trust is removed.

    The certificate file itself is not managed by this type.

    For Debian the provider will create a symbolic link using the certificate
    hash value in the certificate directory.

    @example Mark an existing certificate as trusted

      openssl_trustcert { '/etc/ssl/certs/My-Root-CA.crt':
        ensure => present,
      }

    @example Mark an existing certificate as not trusted

      openssl_trustcert { '/etc/ssl/certs/My-Root-CA.crt':
        ensure => absent,
      }

  DOC

  ensurable do
    desc <<-EOT
      Specifies whether the resource should exist.
    EOT

    defaultvalues
    defaultto :present
  end

  newparam(:certificate, namevar: true) do
    desc 'The name of the certificate file to manage.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end
end
