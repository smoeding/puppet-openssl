# openssl.rb --- Sign openssl certificate signing request files

Puppet::Type.type(:openssl_signcsr).provide(:openssl) do
  desc <<-EOT
    This provider implements the openssl_signcsr type.
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
      Puppet.debug("openssl_signcsr: exists? #{resource[:file]}")

      stdout.each_line { |_| }

      # A process failure indicates that the target file does not have the
      # correct content, so we (re)create the resource.  The process failure
      # is not propagated to Puppet.
      return false unless process_status.value.success?
    end

    true
  end

  def create
    cmd = ['openssl', 'ca']

    cmd << '-batch' << '-create_serial'
    cmd << '-config' << resource[:ca_config]
    cmd << '-name' << resource[:ca_name]

    cmd << '-in' << resource[:csr]
    cmd << '-out' << resource[:file]

    # security: send cipher password on stdin
    cmd << '-passin' << 'stdin' unless resource[:password].nil?

    cmd << '-extfile' << resource[:extfile] unless resource[:extfile].nil?
    cmd << '-extensions' << resource[:extensions] unless resource[:extensions].nil?

    cmd << '-days' << resource[:days]

    Open3.popen2e(*cmd) do |stdin, stdout, process_status|
      Puppet.debug("openssl_signcsr: create #{resource[:file]}")

      stdin.puts(resource[:password]) unless resource[:password].nil?

      out = []
      stdout.each_line { |line| out << line.chomp }

      unless process_status.value.success?
        out.each { |line| Puppet.notice("openssl_signcsr: #{line}") }
        raise Puppet::ExecutionFailure, 'openssl_signcsr: create failed'
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
      Puppet.debug("openssl_signcsr: recreating #{resource[:file]}")
      create
    else
      Puppet.debug("openssl_signcsr: skipping recreation of #{resource[:file]}")
    end
  end
end
