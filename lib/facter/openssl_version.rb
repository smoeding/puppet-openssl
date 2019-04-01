# openssl_version.rb --- get OpenSSL version
if defined?(Facter::Util::Resolution.which) and Facter::Util::Resolution.which('openssl')
  Facter.add(:openssl_version) do
    setcode do
      Facter::Util::Resolution.exec('openssl version').lines.first.match(/OpenSSL ([0-9.]+[a-z])/)[1]
    end
  end
end
