# openssl_revoke.rb --- Revoke an OpenSSL certificate

Puppet::Type.newtype(:openssl_revoke) do
  @doc = <<-DOC
    @summary Revoke an OpenSSL certificate

    The type revokes a certificate by creating a record of the revocation in
    the CA index. The database file can then be used to generate a certificate
    revokation list (CRL).

    The certificate to revoke is identified by the serial number.

    @example Revoke a certificate

      openssl_revoke { '6A71033D32F4D4D3E5A4461BFAB3B907':
        ca_database_file => '/etc/ssl/CA/index.txt',
      }

    @example Remove a revoked certificate

      openssl_revoke { '6A71033D32F4D4D3E5A4461BFAB3B907':
        ensure           => absent,
        ca_database_file => '/etc/ssl/CA/index.txt',
      }
  DOC

  ensurable do
    desc <<-DOC
      The basic property that the resource should be in.
    DOC

    defaultvalues
    defaultto :present
  end

  newparam(:serial, namevar: true) do
    desc 'The serial number of the certificate to revoke.'
  end

  newparam(:ca_database_file) do
    desc 'Required. The file containing the CA database.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  autorequire(:file) do
    [self[:ca_database_file]]
  end

  validate do
    raise Puppet::ParseError, "Parameter 'ca_database_file' is mandatory" if self[:ca_database_file].nil?
  end
end
