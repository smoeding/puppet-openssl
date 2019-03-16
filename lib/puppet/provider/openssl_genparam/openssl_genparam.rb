# openssl_genparam.rb --- Generate openssl parameter files

require 'securerandom'

Puppet::Type.type(:openssl_genparam).provide(:openssl_genparam) do
  commands openssl: 'openssl'

  def exists?
    curve = generator = bits = 0

    # file does not exist
    return false unless File.exist?(resource[:file])

    # parse openssl output for properties
    Open3.popen2('openssl', 'pkeyparam', '-noout', '-text', '-in', resource[:file]) do |_stdin, stdout, process_status|
      Puppet.debug("openssl_genparam: #{resource[:file]} opened")
      stdout.each_line do |line|
        %r{^.*ECDSA-Parameters: \((\d+) bit\)}.match(line) { |m| curve = m[1] }
        %r{^.*DH Parameters: \((\d+) bit\)}.match(line) { |m| bits = m[1] }
        %r{^.*generator: (\d) }.match(line) { |m| generator = m[1] }
      end
      return false unless process_status.value.success?
    end

    Puppet.debug("openssl_genparam: #{resource[:file]} curve=#{curve}")
    Puppet.debug("openssl_genparam: #{resource[:file]} bits=#{bits}")
    Puppet.debug("openssl_genparam: #{resource[:file]} generator=#{generator}")

    # validate
    case resource[:algorithm]
    when 'DH'
      return false unless resource[:bits].to_s == bits
      return false unless resource[:generator].to_s == generator
    when 'EC'
      return false unless resource[:curve].to_s == '0'
    end

    # check get age of file if refresh_interval is set
    unless resource[:refresh_interval].nil?
      age = Time.now - File.stat(resource[:file]).mtime
      Puppet.debug("openssl_genparam: #{resource[:file]} age=#{age}")

      return false unless age < resource[:refresh_interval]
    end

    true
  end

  def create
    # use a temporary file to generate the parameters and rename it when done
    t = resource[:file] + '.' + SecureRandom.uuid

    case resource[:algorithm]
    when 'DH'
      openssl('genpkey', '-genparam', '-algorithm', 'DH', '-out', t,
              '-pkeyopt', "dh_paramgen_prime_len:#{resource[:bits]}",
              '-pkeyopt', "dh_paramgen_generator:#{resource[:generator]}")
    when 'EC'
      openssl('genpkey', '-genparam', '-algorithm', 'EC', '-out', t,
              '-pkeyopt', "ec_paramgen_curve:#{resource[:curve]}")
    end

    File.rename(t, resource[:file])
  end

  def destroy
    File.delete(resource[:file])
  end
end
