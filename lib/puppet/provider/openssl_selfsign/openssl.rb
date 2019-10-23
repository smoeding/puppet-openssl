# openssl.rb --- Create an OpenSSL self-signed certificate

Puppet::Type.type(:openssl_selfsign).provide(:openssl) do
  desc <<-EOT
    This provider implements the openssl_selfsign type.
  EOT

  commands openssl: 'openssl'

  def initialize(value = {})
    super(value)
    @trigger_refresh = true
  end

  def exists?
    return false unless File.exist?(resource[:file])

    cmd = ['openssl', 'x509', '-noout']
    cmd << '-in' << resource[:file]

    Open3.popen2e(*cmd) do |_stdin, stdout, process_status|
      Puppet.debug("openssl_selfsign: exists? #{resource[:file]}")

      stdout.each_line { |_| }

      return false unless process_status.value.success?
    end

    true
  end

  def create
    out = []
    cmd = ['openssl', 'x509']

    cmd << '-req' << '-signkey' << resource[:signkey]

    cmd << '-in' << resource[:csr]
    cmd << '-out' << resource[:file]

    # security: send cipher password on stdin
    cmd << '-passin' << 'stdin' unless resource[:password].nil?

    cmd << '-extfile' << resource[:extfile] unless resource[:extfile].nil?
    cmd << '-extensions' << resource[:extensions] unless resource[:extensions].nil?

    cmd << '-days' << resource[:days]

    Open3.popen2e(*cmd) do |stdin, stdout, process_status|
      Puppet.debug("openssl_selfsign: create #{resource[:file]}")

      stdin.puts(resource[:password]) unless resource[:password].nil?

      stdout.each_line { |line| out << line }

      unless process_status.value.success?
        out.each { |line| Puppet.notice("openssl_selfsign: #{line}") }
        return false
      end
    end
    @trigger_refresh = false
  end

  def destroy
    File.unlink(resource[:file])
    @trigger_refresh = false
  end

  def refresh
    if @trigger_refresh
      Puppet.debug("openssl_selfsign: recreating #{resource[:file]}")
      create
    else
      Puppet.debug("openssl_selfsign: skipping recreation of #{resource[:file]}")
    end
  end
end
