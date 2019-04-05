# openssl_signcsr.rb --- Sign openssl certificate signing request files

Puppet::Type.type(:openssl_signcsr).provide(:openssl_signcsr) do
  desc <<-EOT
    This provider implements the openssl_signcsr type.
  EOT

  commands openssl: 'openssl'

  def exists?
    return false unless File.exist?(resource[:file])

    param = ['openssl', 'x509', '-noout']
    param << '-in' << resource[:file]

    Open3.popen2e(*param) do |stdin, stdout, process_status|
      Puppet.debug("openssl_signcsr: exists? #{resource[:file]}")

      # Ignore output
      stdout.each_line { |_| }

      return false unless process_status.value.success?
    end

    true
  end

  def create
    cre_param = ['openssl', 'req', '-new', '-x509']

    cre_param << '-out' << resource[:file]
    cre_param << '-in' << resource[:csr_file]
    cre_param << '-key' << resource[:key_file]
    cre_param << '-config' << resource[:cnf_file]
    cre_param << '-days' << resource[:days]

    # it is more secure to send cipher password on stdin
    cre_param << '-passin' << 'stdin' unless resource[:key_password].nil?

    Open3.popen2e(*cre_param) do |stdin, stdout, process_status|
      Puppet.debug("openssl_signcsr: create #{resource[:file]}")

      stdin.puts(resource[:key_password]) unless resource[:key_password].nil?

      stdout.each_line { |_| }

      return false unless process_status.value.success?
    end
  end

  def destroy
    File.unlink(resource[:file])
  end
end
