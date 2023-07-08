# openssl_hash.rb --- Manage certificate hash as symbolic link

Puppet::Type.newtype(:openssl_hash) do
  @doc = <<-DOC
    @summary Manage a symbolic link using the certificate hash

    If `ensure => present` a symbolic link using the certificate hash will be
    created in the same directory as the certificate. The link is removed if
    `ensure => absent`.

    This link is used to find a trusted cert when a certificate chain is
    validated.

    The certificate file itself is not managed by this type.

    The file must exist before the link can be created as it is accessed by
    OpenSSL to calculate the hash. For the same reason the file can only be
    deleted after the link has been removed.

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
    desc <<-DOC
    The basic property that the resource should be in.
  DOC

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
