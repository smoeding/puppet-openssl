# openssl_genpkey.rb --- Generate openssl private key files

Puppet::Type.newtype(:openssl_genpkey) do
  desc <<-DOC
    @summary Generate OpenSSL private key files.

    The type generates OpenSSL private key file. The key can optionally be
    encrypted using a supplied password.

    @example Generate RSA private key using 2048 bits

      openssl_genpkey { '/tmp/rsa-2048.key':
        algorithm => 'RSA',
        bits      => '2048',
      }

    @example Generate EC private key using secp521r1 curve

      openssl_genpkey { '/tmp/ec-secp521r1.key':
        algorithm => 'EC',
        curve     => 'secp521r1',
      }

    @example Generate AES encrypted EC private key using secp256k1 curve

      openssl_genpkey { '/tmp/ec-secp256k1.key':
        algorithm => 'EC',
        curve     => 'secp256k1',
        cipher    => 'aes128',
        password  => 'rosebud',
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
    desc 'The algorithm to generate a private key for. The number of bits
      must be supplied if an RSA key is generated. For an EC key the curve
      name must be given'

    newvalues('RSA', 'EC')
    munge { |value| value.to_s }

    validate do |value|
      raise Puppet::Error, 'Parameter algorithm is mandatory' if value.nil?
    end
  end

  newparam(:bits) do
    desc 'The number of bits for the RSA key. Must be one of the strings
      `2048`, `4096` or `8192`. This parameter is mandatory for RSA keys.'

    newvalues('2048', '4096', '8192')
    munge { |value| value.to_s }
  end

  newparam(:curve) do
    desc 'The curve to use for elliptic curve key. This parameter is
      mandatory for EC keys.'

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