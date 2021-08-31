# openssl.rb --- Generate openssl parameter files

require 'securerandom'

Puppet::Type.type(:openssl_genparam).provide(:openssl) do
  desc <<-EOT
    This provider implements the openssl_genparam type.
  EOT

  commands openssl: 'openssl'

  def initialize(value = {})
    super(value)
    @trigger_refresh = true
  end

  def exists?
    return false unless File.exist?(resource[:file])

    param = ['openssl', 'pkeyparam', '-noout', '-text']
    param << '-in' << resource[:file]

    Open3.popen2(*param) do |_stdin, stdout, process_status|
      Puppet.debug("openssl_genparam: #{resource[:file]} opened")

      out = []
      stdout.each_line { |line| out << line.chomp }

      unless process_status.value.success?
        out.each { |line| Puppet.notice("openssl_genparam: #{line}") }
        raise Puppet::ExecutionFailure, 'openssl_genparam: exists? failed'
      end
    end

    # check age of file if refresh_interval is set
    unless resource[:refresh_interval].nil?
      age = Time.now - File.stat(resource[:file]).mtime
      Puppet.debug("openssl_genparam: #{resource[:file]} file age=#{age}")

      return false unless age < resource[:refresh_interval]
    end

    true
  end

  def create
    cre_param = ['genpkey', '-genparam']

    # use a temporary file to generate the parameters and rename it when done
    tfile = resource[:file] + '.' + SecureRandom.uuid
    cre_param << '-out' << tfile

    case resource[:algorithm]
    when 'DH'
      cre_param << '-algorithm' << 'DH'
      cre_param << '-pkeyopt' << "dh_paramgen_prime_len:#{resource[:bits]}"
      cre_param << '-pkeyopt' << "dh_paramgen_generator:#{resource[:generator]}"
    when 'EC'
      cre_param << '-algorithm' << 'EC'
      cre_param << '-pkeyopt' << "ec_paramgen_curve:#{resource[:curve]}"
      # cre_param << '-pkeyopt' << 'ec_param_enc:named_curve'
    end

    # generate parameter file
    openssl(*cre_param)

    File.rename(tfile, resource[:file])
  ensure
    File.unlink(tfile) if File.exist?(tfile)
    @trigger_refresh = false
  end

  def destroy
    File.unlink(resource[:file])
    @trigger_refresh = false
  end

  def refresh
    if @trigger_refresh
      Puppet.debug("openssl_genparam: recreating #{resource[:file]}")
      create
    else
      Puppet.debug("openssl_genparam: skipping recreation of #{resource[:file]}")
    end
  end
end
