# openssl_certutil.rb --- Manage trusted certificates using certutil

Puppet::Type.newtype(:openssl_certutil) do
  desc <<-DOC
    @summary Manage trusted certificates in the system-wide NSS database.

    The certificate specified with 'filename' is installed as a trusted
    certificate if 'ensure => present'. If 'ensure => absent' the trust is
    removed.

    The certificate file itself is not managed by this type.

    @example Mark an existing certificate as trusted for SSL

      openssl_certutil { '/etc/ssl/certs/My-Root-CA.crt':
        ensure    => present,
        ssl_trust => 'C',
      }

    @example Mark an existing certificate as not trusted

      openssl_certutil { '/etc/ssl/certs/My-Root-CA.crt':
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
    desc 'The nickname of the certificate in the certificate database.'
  end

  newparam(:filename) do
    desc 'The filename of the certificate.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newproperty(:ssl_trust) do
    desc 'SSL trust attributes for the certificate.'
    newvalues(%r{[pPcCT]*})
    munge { |value| value.chars.sort.join unless value.nil? }
  end

  newproperty(:email_trust) do
    desc 'Email trust attributes for the certificate.'
    newvalues(%r{[pPcCT]*})
    munge { |value| value.chars.sort.join unless value.nil? }
  end

  newproperty(:object_signing_trust) do
    desc 'Object signing trust attributes for the certificate.'
    newvalues(%r{[pPcCT]*})
    munge { |value| value.chars.sort.join unless value.nil? }
  end

  validate do
    unless self[:filename]
      unless self[:ensure].to_s == 'absent'
        raise(Puppet::Error, 'Parameter filename is a required attribute')
      end
    end
  end
end
