# openssl_genpkey.rb --- Generate openssl private key files

require 'securerandom'

Puppet::Type.type(:openssl_genpkey).provide(:openssl_genpkey) do
  desc <<-EOT
    This provider implements the openssl_genpkey type.
  EOT

  commands openssl: 'openssl'

  def exists?
    param = ['openssl', 'pkey', '-noout', '-text']

    # file does not exist
    return false unless File.exist?(resource[:file])
    param << '-in' << resource[:file]

    # send cipher password on stdin for security reasons
    unless resource[:cipher].nil? || resource[:password].nil?
      param << "-#{resource[:cipher]}"
      param << '-passin' << 'stdin'
    end

    Open3.popen2(*param) do |stdin, stdout, process_status|
      Puppet.debug("openssl_genpkey: exists? #{resource[:file]}")

      stdin.puts(resource[:password]) unless resource[:password].nil?

      # Ignore output
      stdout.each_line { |_| }

      return false unless process_status.value.success?
    end

    true
  end

  def create
    param = ['openssl', 'genpkey']

    param << '-paramfile' << resource[:paramfile]

    # use a temporary file to generate the parameters and rename it when done
    sfile = resource[:file] + '.' + SecureRandom.uuid
    param << '-out' << sfile

    # send cipher password on stdin for security reasons
    unless resource[:cipher].nil? || resource[:password].nil?
      param << "-#{resource[:cipher]}"
      param << '-pass' << 'stdin'
    end

    case resource[:algorithm]
    when 'RSA'
      param << '-pkeyopt' << "rsa_keygen_bits:#{resource[:bits]}"
    when 'EC'
      param << '-pkeyopt' << "ec_paramgen_curve:#{resource[:curve]}"
      param << '-pkeyopt' << 'ec_param_enc:named_curve'
    end

    Open3.popen2(*param) do |stdin, stdout, process_status|
      Puppet.debug("openssl_genpkey: create #{resource[:file]}")

      stdin.puts(resource[:password]) unless resource[:password].nil?

      # Ignore output
      stdout.each_line { |_| }

      return false unless process_status.value.success?
    end

    File.rename(sfile, resource[:file])
  end

  def destroy
    File.delete(resource[:file])
  end
end
