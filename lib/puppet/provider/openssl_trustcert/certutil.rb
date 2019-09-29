# certutil.rb --- Create a trusted certificate using certutil

Puppet::Type.type(:openssl_trustcert).provide(:certutil) do
  desc <<-EOT
    This provider implements the openssl_trustcert type using certutil.
  EOT

  confine    osfamily: :redhat
  defaultfor osfamily: :redhat
  commands   certutil: 'certutil'

  def self.instances
    certs = []
    certutil('-L', '-d', 'sql:/etc/pki/nssdb').each_line do |line|
      match = line.match(%r{^(.*)\s+([pPcTCu,]+)\s*$})
      next unless match

      nickname, _trust = match.captures
      nickname.strip!
      Puppet.debug("openssl_trustcert: found instance #{nickname}")
      certs << new(name: nickname, ensure: :present)
    end
    certs
  end

  def self.prefetch(resources)
    certificates = instances

    resources.keys.each do |name|
      provider = certificates.find { |crt| crt.name == name }
      resources[name].provider = provider if provider
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    Puppet.debug("openssl_trustcert: create #{@resource[:certificate]}")
    certutil('-A', '-d', 'sql:/etc/pki/nssdb', '-t', 'C,,', '-n', @resource[:certificate], '-i', @resource[:certificate])
  end

  def destroy
    Puppet.debug("openssl_trustcert: destroy #{@resource[:certificate]}")
    certutil('-D', '-d', 'sql:/etc/pki/nssdb', '-n', @resource[:certificate])
  end
end
