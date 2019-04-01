# openssl_genpkey.rb --- Generate openssl private key files

require 'securerandom'
require 'tempfile'

Puppet::Type.type(:openssl_genpkey).provide(:openssl_genpkey) do
  desc <<-EOT
    This provider implements the openssl_genpkey type.
  EOT

  commands openssl: 'openssl'

  def exists?
    # file does not exist
    return false unless File.exist?(resource[:file])

    param = ['openssl', 'pkey', '-noout', '-text']
    param << '-in' << resource[:file]

    # it is more secure to send cipher password on stdin
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
    cre_param = ['openssl', 'genpkey']
    ptemp = nil

    if resource[:paramfile].nil?
      # no paramfile so generate a temporary parameter file
      ptemp = Tempfile.new(['openssl_genpkey', '.pem'])
      raise Puppet::Error, 'Failed to create temporary file' if ptemp.nil?

      # close the file as another program will need to write it
      ptemp.close

      # build command to generate the temporary parameter file
      gen_param = ['genpkey', '-genparam']

      case resource[:algorithm]
      when 'RSA'
        gen_param << '-algorithm' << 'DH'
        gen_param << '-pkeyopt' << "dh_paramgen_prime_len:#{resource[:bits]}"
        gen_param << '-pkeyopt' << "dh_paramgen_generator:#{resource[:generator]}"
      when 'EC'
        gen_param << '-algorithm' << 'EC'
        gen_param << '-pkeyopt' << "ec_paramgen_curve:#{resource[:curve]}"
        #gen_param << '-pkeyopt' << 'ec_param_enc:named_curve'
      end

      gen_param << '-out' << ptemp.path

      # generate parameter file
      openssl(*gen_param)

      cre_param << '-paramfile' << ptemp.path
    else
      # use supplied parameter file
      cre_param << '-paramfile' << resource[:paramfile]
    end

    # use a temporary file to generate the parameters and rename it when done
    tfile = resource[:file] + '.' + SecureRandom.uuid
    cre_param << '-out' << tfile

    # it is more secure to send cipher password on stdin
    unless resource[:cipher].nil? || resource[:password].nil?
      cre_param << "-#{resource[:cipher]}"
      cre_param << '-pass' << 'stdin'
    end

    Open3.popen2(*cre_param) do |stdin, stdout, process_status|
      Puppet.debug("openssl_genpkey: create #{resource[:file]}")

      stdin.puts(resource[:password]) unless resource[:password].nil?

      # Ignore output
      stdout.each_line { |_| }

      return false unless process_status.value.success?
    end

    ptemp.unlink unless ptemp.nil?
    File.rename(tfile, resource[:file])
  end

  def destroy
    File.delete(resource[:file])
  end
end
