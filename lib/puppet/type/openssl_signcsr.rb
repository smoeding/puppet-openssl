# openssl_signcsr.rb --- Sign openssl CSR files

Puppet::Type.newtype(:openssl_signcsr) do
  desc <<-DOC
    @summary Sign OpenSSL certificate signing request

    Take a certificate signing request (CSR), a config file providing the
    cedrtificate extensions and a key file to generate a certificate. The
    certificate will be valid for the given number of days. An encrypted key
    can be used if the key password is supplied.

    @example Sign a certificate for one year

      openssl_signcert { '/tmp/cert.crt':
        csr      => '/tmp/csr',
        config   => '/tmp/cert.cnf',
        key_file => '/tmp/cert.key',
        days     => '365',
      }

  DOC

  ensurable do
    desc <<-EOT
      Specifies whether the resource should exist.
    EOT

    defaultvalues
    defaultto :present
  end

  newparam(:file, namevar: true) do
    desc 'The name of the signed certificate file to manage.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:csr_file) do
    desc 'The file containing the certificate signing request.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:cnf_file) do
    desc 'The configuration file.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:key_file) do
    desc 'The file with the key to use for the signature.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:key_password) do
    desc 'Use the supplied password for the key if it is encrypted.'

    munge { |value| value.to_s }
  end

  newparam(:days) do
    desc 'The number of days the certificate should be valid.'

    munge { |value| value.to_s }
  end

  autorequire(:file) do
    [self[:csr_file], self[:cnf_file]]
  end

  autorequire(:openssl_genpkey) do
    [self[:key_file]]
  end
end
