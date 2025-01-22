# ruby.rb --- Revoke an OpenSSL certificate

require_relative '../../../puppet_x/stm/openssl/cadb'

Puppet::Type.type(:openssl_revoke).provide(:ruby) do
  desc <<-EOT
    This provider implements the openssl_revoke type using Ruby.
  EOT

  def exists?
    PuppetX::OpenSSL::CADB.read(resource[:ca_database_file]) do |db|
      db.each do |line|
        next unless (match = line.match(PuppetX::OpenSSL::CADB::DB_LINE_FORMAT))

        status, _expdate, _revdate, serial, _certfile, _subj = match.captures

        return false if serial.casecmp(resource[:serial]).zero? &&
                        status == PuppetX::OpenSSL::CADB::VALID
      end
    end

    resource[:ensure] == :present
  end

  def create
    PuppetX::OpenSSL::CADB.read(resource[:ca_database_file]) do |old|
      PuppetX::OpenSSL::CADB.replace(resource[:ca_database_file]) do |new|
        old.each do |line|
          next unless (match = line.match(PuppetX::OpenSSL::CADB::DB_LINE_FORMAT))

          status, expdate, revdate, serial, certfile, subj = match.captures

          # Revoke the certificate if it matches
          if serial.casecmp(resource[:serial]).zero? &&
             status == PuppetX::OpenSSL::CADB::VALID
            status = PuppetX::OpenSSL::CADB::REVOKED
            revdate = PuppetX::OpenSSL::CADB.timestamp(Time.now)
          end

          new.puts status + "\t" + expdate + "\t" + revdate + "\t" + serial + "\t" + certfile + "\t" + subj
        end
      end
    end
  end

  def destroy
    PuppetX::OpenSSL::CADB.read(resource[:ca_database_file]) do |old|
      PuppetX::OpenSSL::CADB.replace(resource[:ca_database_file]) do |new|
        old.each do |line|
          next unless (match = line.match(PuppetX::OpenSSL::CADB::DB_LINE_FORMAT))

          status, expdate, revdate, serial, certfile, subj = match.captures

          # Skip the certificate if it matches
          next if serial.casecmp(resource[:serial]).zero? &&
                  status == PuppetX::OpenSSL::CADB::REVOKED

          new.puts status + "\t" + expdate + "\t" + revdate + "\t" + serial + "\t" + certfile + "\t" + subj
        end
      end
    end
  end

  mk_resource_methods
end
