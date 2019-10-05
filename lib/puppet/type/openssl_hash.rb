# openssl_hash.rb --- Manage certificate hash as symbolic link

Puppet::Type.newtype(:openssl_hash) do
  desc <<-DOC
    @summary Manage certificate hash as symbolic link

    The certificate file is installed as a trusted certificate if
    'ensure => present'. If 'ensure => absent' the trust is removed.

    The certificate file itself is not managed by this type.

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

  newparam(:name) do
    desc 'The name of the certificate file to manage.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end
end
