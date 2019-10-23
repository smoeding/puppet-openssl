# openssl_certutil.rb --- Manage trusted certificates using certutil

Puppet::Type.newtype(:openssl_certutil) do
  @doc = <<-DOC
    @summary Manage trusted certificates in the system-wide NSS database

    This type installs the certificate specified with `filename` as a trusted
    certificate if `ensure => present`. The trust is removed if `ensure =>
    absent`.

    The `certutil` executable is required for this type. In general it is
    only available on RedHat-based distributions.

    The certificate file itself is not managed by this type.

    The file must already exist on the node before it can be added to the NSS
    database. Make sure you add the correct dependency if you manage the
    certificate file with Puppet.

    There is an unsolved issue if a certificate is added a second time to the
    NSS database using a different name. In this case `certutil` does not add
    the certificate but also does not report an error. Therefore Puppet will
    try to add the certificate every time it runs. As a workaround the
    already installed certificate should be removed.

    @example Add a certificate to the NSS database and set trust level for SSL

      openssl_certutil { '/etc/ssl/certs/My-Root-CA.crt':
        ensure    => present,
        ssl_trust => 'C',
      }

    @example Remove a certificate from the NSS database

      openssl_certutil { '/etc/ssl/certs/My-Root-CA.crt':
        ensure => absent,
      }
  DOC

  ensurable do
    desc 'Specifies whether the resource should exist.'

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
    newvalues %r{[pPcCT]*}

    munge { |value| value.chars.sort.join unless value.nil? }
  end

  newproperty(:email_trust) do
    desc 'Email trust attributes for the certificate.'
    newvalues %r{[pPcCT]*}

    munge { |value| value.chars.sort.join unless value.nil? }
  end

  newproperty(:object_signing_trust) do
    desc 'Object signing trust attributes for the certificate.'
    newvalues %r{[pPcCT]*}

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
