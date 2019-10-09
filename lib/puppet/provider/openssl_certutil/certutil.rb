# certutil.rb --- Manage trusted certificates using certutil

Puppet::Type.type(:openssl_certutil).provide(:certutil) do
  desc <<-EOT
    This provider implements the openssl_certutil type.
  EOT

  commands certutil: 'certutil'

  NSSDATABASE = 'sql:/etc/pki/nssdb'.freeze

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.canonicalize_trustargs(value)
    # Map nil to the empty string, otherwise delete 'u' and sort chars
    value.nil? ? '' : value.delete('u').chars.sort.join
  end

  def self.instances
    certs = []
    certutil('-L', '-d', NSSDATABASE).each_line do |line|
      match = line.match(%r{^(.*\S)\s+([pPcTCu]*),([pPcTCu]*),([pPcTCu]*)\s*$})
      next unless match

      name, ssl, email, object_signing = match.captures

      Puppet.debug("openssl_certutil: found instance #{name}")
      certs << new(name: name,
                   ensure: :present,
                   ssl_trust: canonicalize_trustargs(ssl),
                   email_trust: canonicalize_trustargs(email),
                   object_signing_trust: canonicalize_trustargs(object_signing))
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

  def ssl_trust
    @property_hash[:ssl_trust]
  end

  def email_trust
    @property_hash[:email_trust]
  end

  def object_signing_trust
    @property_hash[:object_signing_trust]
  end

  def ssl_trust=(value)
    @property_flush[:ssl_trust] = value
  end

  def email_trust=(value)
    @property_flush[:email_trust] = value
  end

  def object_signing_trust=(value)
    @property_flush[:object_signing_trust] = value
  end

  def flush
    Puppet.debug("openssl_certutil: flush #{resource[:name]}")

    unless @property_flush.empty?
      trust = []
      trust << (@property_flush[:ssl_trust] || resource[:ssl_trust])
      trust << (@property_flush[:email_trust] || resource[:email_trust])
      trust << (@property_flush[:object_signing_trust] || resource[:object_signing_trust])

      args = ['-M', '-d', NSSDATABASE]
      args << ['-n', resource[:name]]
      args << ['-t', trust.join(',')]

      certutil(*args)
    end

    @property_hash = resource.to_hash
  end

  def create
    Puppet.debug("openssl_certutil: create #{resource[:name]}")

    trust = [resource[:ssl_trust], resource[:email_trust], resource[:object_signing_trust]]

    args = ['-A', '-d', NSSDATABASE]
    args << ['-n', resource[:name]]
    args << ['-t', trust.join(',')]
    args << ['-i', resource[:filename]]

    certutil(*args)

    @property_hash = resource.to_hash
  end

  def destroy
    Puppet.debug("openssl_certutil: destroy #{resource[:name]}")

    args = ['-D', '-d', NSSDATABASE]
    args << ['-n', resource[:name]]

    certutil(*args)

    @property_hash.clear
  end
end
