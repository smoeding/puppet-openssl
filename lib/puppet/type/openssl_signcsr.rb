# openssl_signcsr.rb --- Sign openssl CSR files

Puppet::Type.newtype(:openssl_signcsr) do
  desc <<-DOC
    @summary Sign OpenSSL certificate signing request
  DOC

  ensurable do
    desc <<-EOT
      Specifies whether the resource should exist.
    EOT

    defaultvalues
    defaultto :present
  end

  newparam(:file, namevar: true) do
    desc 'The name of the signed CSR file to manage.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:csr_file) do
    desc 'The file with the certificate signing request.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:config_file) do
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

  newparam(:password) do
    desc 'Use the supplied password when encrypting the key.'

    munge { |value| value.to_s }
  end

  newparam(:days) do
    desc 'The number of days the certificate should be valid.'

    munge { |value| value.to_s }
  end

  autorequire(:file) do
    [self[:csr_file].value, self[:config_file].value]
  end

  autorequire(:openssl_genpkey) do
    [self[:key_file]]
  end
end
