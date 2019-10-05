# openssl.rb --- Manage certificate hash as symbolic link

Puppet::Type.type(:openssl_hash).provide(:openssl) do
  desc <<-EOT
    This provider implements the openssl_hash type.
  EOT

  commands openssl: 'openssl'

  def gethash(certificate)
    param = ['openssl', 'x509', '-noout', '-hash']
    param << '-in' << certificate

    hash, status = Open3.capture2(*param)

    if status.success?
      hash.chomp!
      Puppet.debug("openssl_hash: #{certificate} has hash '#{hash}'")
      hash
    else
      Puppet.debug('openssl_hash: unable to get certificate hash')
      nil
    end
  end

  def exists?
    return false unless File.exist?(resource[:name])

    path = File.dirname(resource[:name])
    hash = gethash(resource[:name])

    return false if hash.nil?

    link = File.join(path, hash + '.0')
    return false unless File.exist?(link)

    Puppet.debug("openssl_hash: #{link} exists")

    return false unless File.symlink?(link)

    Puppet.debug("openssl_hash: #{link} is a symlink")

    linkdest = File.readlink(link)

    Puppet.debug("openssl_hash: #{link} -> #{linkdest}")

    return false unless linkdest == resource[:name]

    true
  end

  def create
    path = File.dirname(resource[:name])
    hash = gethash(resource[:name])
    link = File.join(path, hash + '.0')

    Puppet.debug("openssl_hash: creating #{link} -> #{resource[:name]}")

    # First remove old entry
    File.unlink(link) if File.exist?(link)
    File.symlink(resource[:name], link)
  end

  def destroy
    path = File.dirname(resource[:name])
    hash = gethash(resource[:name])
    link = File.join(path, hash + '.0')

    Puppet.debug("openssl_hash: removing #{link}")

    File.unlink(link)
  end
end
