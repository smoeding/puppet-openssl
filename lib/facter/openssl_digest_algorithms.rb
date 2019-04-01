# openssl_digest_algorithms.rb --- get digest algorithms supported by OpenSSL
if defined?(Facter::Util::Resolution.which) and Facter::Util::Resolution.which('openssl')
  Facter.add('openssl_digest_algorithms') do
    setcode do
      algs = []
      output = Facter::Util::Resolution.exec("openssl list -digest-algorithms 2>&1")
      unless output.nil?
        output.each_line do |line|
          %r{^(\S+)}.match(line) { |m| algs << m[1] }
        end
      end
      algs.sort.uniq
    end
  end
end
