# openssl_genparam.rb --- Generate openssl parameter files

require 'securerandom'

Puppet::Type.type(:openssl_genparam).provide(:openssl_genparam) do
  desc <<-EOT
    This provider implements the openssl_genparam type.
  EOT

  commands openssl: 'openssl'

  def exists?
    return false unless File.exist?(resource[:file])

    param = ['openssl', 'pkeyparam', '-noout', '-text']
    param << '-in' << resource[:file]

    Open3.popen2(*param) do |_stdin, stdout, process_status|
      Puppet.debug("openssl_genparam: #{resource[:file]} opened")

      # ignore output
      stdout.each_line { |_| }

      return false unless process_status.value.success?
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
  end

  def destroy
    File.unlink(resource[:file])
  end
end
