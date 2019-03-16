# openssl_genpkey.rb --- Generate openssl private key files

Puppet::Type.newtype(:openssl_genpkey) do
  desc <<-DOC
    Generate OpenSSL private key files.

    Example for a RSA private key using 2048 bits:

      openssl_genpkey { '/tmp/rsa248.key':
        algorithm => 'RSA',
        bits      => '2048',
      }
  DOC

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:file, namevar: true) do
    desc 'The name of the private key file to manage.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:algorithm) do
    desc 'The algorithm to generate a private key for.'

    newvalues('RSA', 'EC')
    munge { |value| value.to_s }

    validate do |value|
      raise Puppet::Error, 'Parameter algorithm is mandatory' if value.nil?
    end
  end

  newparam(:bits) do
    desc 'The number of bits for the RSA key. Must be one of the strings
      `2048`, `4096` or `8192`.'

    newvalues('2048', '4096', '8192')
    munge { |value| value.to_s }
  end

  newparam(:curve) do
    desc 'The curve to use for elliptic curve key.'

    newvalues(%r{^[a-zA-Z][a-zA-Z0-9-]+[0-9]$})
    munge { |value| value.to_s }
  end

  newparam(:cipher) do
    desc 'Encrypt the key with the supplied cipher. A password must be given
      in this case.'

    munge { |value| value.to_s }
  end

  newparam(:password) do
    desc 'Use the supplied password when encrypting the key.'

    munge { |value| value.to_s }
  end

  validate do
    case self[:algorithm]
    when 'RSA'
      raise Puppet::Error, 'Parameter bits is mandatory for RSA keys' if self[:bits].nil?
    when 'EC'
      raise Puppet::Error, 'Parameter curve is mandatory for EC keys' if self[:curve].nil?
    end

    if !self[:cipher].nil? && self[:password].nil?
      raise Puppet::Error, 'A password must be given when encryption is used.'
    end
  end
end
