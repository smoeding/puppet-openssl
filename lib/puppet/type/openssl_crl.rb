# frozen_string_literal: true

require 'openssl'
require 'puppet/type/file/owner'
require 'puppet/type/file/group'
require 'puppet/type/file/mode'
require 'puppet/parameter/boolean'

require_relative '../../puppet_x/stm/openssl/cadb'

Puppet::Type.newtype(:openssl_crl) do
  desc <<-DOC
    @summary Create an OpenSSL certificate revocation list

    The type reads the CA database file passed as argument and creates a CRL
    for revoked certificates. The CRL is created using the issuer key and
    certificate.

    The type is refreshable and will generate a new certificate revocation
    list if the resource is notified.

    This type uses the Ruby OpenSSL library and does not need the `openssl`
    binary provided by the operating system.

    **Autorequires:** If Puppet is managing the OpenSSL issuer key and
    issuer certificate that is used to create the CRL, the `openssl_crl`
    resource will autorequire these resources

    @example Create a CRL for a local CA

      openssl_crl { '/etc/ssl/ca.crl':
        crl_serial_file     => '/etc/ssl/crl.serial
        ca_database         => '/etc/ssl/ca.database',
        issuer_cert         => '/etc/ssl/ca.crt',
        issuer_key          => '/etc/ssl/ca.key',
        issuer_key_password => 'rosebud',
        days                => 14,
        mode                => '0644',
      }
  DOC

  ensurable do
    desc <<-DOC
      The basic property that the resource should be in.
    DOC

    defaultvalues
    defaultto :present
  end

  newparam(:path, namevar: true) do
    desc <<-DOC
      Specifies the destination file. Valid options: a string containing an
      absolute path. Default value: the title of your declared resource.
    DOC

    validate do |value|
      unless Puppet::Util.absolute_path?(value, :posix) || Puppet::Util.absolute_path?(value, :windows)
        raise ArgumentError, _("File paths must be fully qualified, not '%{_value}'") % { _value: value }
      end
    end
  end

  newparam(:owner, parent: Puppet::Type::File::Owner) do
    desc <<-DOC
      Specifies the owner of the destination file. Valid options: a string
      containing a username or integer containing a uid.
    DOC
  end

  newparam(:group, parent: Puppet::Type::File::Group) do
    desc <<-DOC
      Specifies a permissions group for the destination file. Valid options:
      a string containing a group name or integer containing a gid.
    DOC
  end

  newparam(:mode, parent: Puppet::Type::File::Mode) do
    desc <<-DOC
      Specifies the permissions mode of the destination file. Valid options:
      a string containing a permission mode value in octal notation.
    DOC
  end

  newparam(:backup) do
    desc <<-DOC
      Specifies whether (and how) to back up the destination file before
      overwriting it. Your value gets passed on to Puppet's native file
      resource for execution. Valid options: true, false, or a string
      representing either a target filebucket or a filename extension
      beginning with ".".
    DOC

    validate do |value|
      raise ArgumentError, _('Backup must be a Boolean or String') unless [TrueClass, FalseClass, String].include?(value.class)
    end
  end

  newparam(:selinux_ignore_defaults, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc <<-DOC
      See the file type's selinux_ignore_defaults documentention:
      https://docs.puppetlabs.com/references/latest/type.html#file-attribute-selinux_ignore_defaults.
    DOC
  end

  newparam(:selrange) do
    desc <<-DOC
      See the file type's selrange documentation:
      https://docs.puppetlabs.com/references/latest/type.html#file-attribute-selrange
    DOC

    validate do |value|
      raise ArgumentError, _('Selrange must be a String') unless value.is_a?(String)
    end
  end

  newparam(:selrole) do
    desc <<-DOC
      See the file type's selrole documentation:
      https://docs.puppetlabs.com/references/latest/type.html#file-attribute-selrole
    DOC

    validate do |value|
      raise ArgumentError, _('Selrole must be a String') unless value.is_a?(String)
    end
  end

  newparam(:seltype) do
    desc <<-DOC
      See the file type's seltype documentation:
      https://docs.puppetlabs.com/references/latest/type.html#file-attribute-seltype
    DOC

    validate do |value|
      raise ArgumentError, _('Seltype must be a String') unless value.is_a?(String)
    end
  end

  newparam(:seluser) do
    desc <<-DOC
      See the file type's seluser documentation:
      https://docs.puppetlabs.com/references/latest/type.html#file-attribute-seluser
    DOC

    validate do |value|
      raise ArgumentError, _('Seluser must be a String') unless value.is_a?(String)
    end
  end

  newparam(:show_diff, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc <<-DOC
      Specifies whether to set the show_diff parameter for the file
      resource.
    DOC
  end

  newparam(:issuer_cert) do
    desc <<-DOC
      The path to the certificate file that is used to issue the certificate.
    DOC

    validate do |value|
      unless Puppet::Util.absolute_path? value
        raise ArgumentError, "Invalid issuer_cert file path #{value}"
      end
    end
  end

  newparam(:issuer_key) do
    desc <<-DOC
      The path to the key file that is used to issue the certificate.
    DOC

    validate do |value|
      unless Puppet::Util.absolute_path? value
        raise ArgumentError, "Invalid issuer_key file path #{value}"
      end
    end
  end

  newparam(:issuer_key_password) do
    desc <<-DOC
      The password to use when loading a protected issuer key.
    DOC

    defaultto ''
  end

  newparam(:days) do
    desc <<-DOC
      The number of days that the CRL should be valid.
    DOC

    munge { |value| value.to_i }

    defaultto 30
    newvalues %r{^[0-9]+$}
  end

  newparam(:signature_algorithm) do
    desc <<-DOC
      The signature algorithm to use. The algorithms `md2`, `md4`, `md5`,
      `sha` and `sha1` are only included for backwards compatibility and
      should be considered insecure for new certificates.
    DOC

    defaultto :sha256
    newvalues :md2, :md4, :md5, :sha, :sha1, :sha224, :sha256, :sha384, :sha512
  end

  newparam(:ca_database_file) do
    desc <<-DOC
      Specifies the path to the CA database file. All certificates marked as
      revoked in this file will be added to the CRL.
      Valid options: a string containing an absolute path.
    DOC

    validate do |value|
      unless Puppet::Util.absolute_path?(value, :posix) || Puppet::Util.absolute_path?(value, :windows)
        raise ArgumentError, _("File paths must be fully qualified, not '%{_value}'") % { _value: value }
      end
    end
  end

  newparam(:crl_serial_file) do
    desc <<-DOC
      Specified the path to the CRL serial number file. The file should
      exist and contain a single line with a decimal number representing the
      serial number of the next CRL that will be created.

      Valid options: a string containing an absolute path.
    DOC

    validate do |value|
      unless Puppet::Util.absolute_path?(value, :posix) || Puppet::Util.absolute_path?(value, :windows)
        raise ArgumentError, _("File paths must be fully qualified, not '%{_value}'") % { _value: value }
      end
    end
  end

  autorequire(:file) do
    [self[:path], self[:ca_database_file], self[:crl_serial_file]]
  end

  autorequire(:openssl_key) do
    [self[:issuer_key]]
  end

  autorequire(:openssl_cert) do
    [self[:issuer_cert]]
  end

  def validate
    return unless self[:ensure] == :present

    raise ArgumentError, "Parameter 'issuer_key' is mandatory" if self[:issuer_key].nil?
    raise ArgumentError, "Parameter 'issuer_cert' is mandatory" if self[:issuer_cert].nil?
    raise ArgumentError, "Parameter 'ca_database_file' is mandatory" if self[:ca_database_file].nil?
    raise ArgumentError, "Parameter 'crl_serial_file' is mandatory" if self[:crl_serial_file].nil?
  end

  def exists?
    self[:ensure] == :present
  end

  def content
    unless @generated_content
      crl = OpenSSL::X509::CRL.new
      crl.version = 1

      # Issuer certificate
      issuer = OpenSSL::X509::Certificate.new File.open(self[:issuer_cert])
      crl.issuer = issuer.subject

      # Issuer key
      issuer_key = begin
                     pem = File.open(self[:issuer_key])
                     OpenSSL::PKey.read pem, self[:issuer_key_password]
                   rescue
                     raise Puppet::Error, 'Unable to load key (missing password?)'
                   end

      # Set validiy of CRL
      crl.last_update = Time.now
      crl.next_update = Time.now + (86_400 * self[:days])

      # Add extension with serial number of CRL
      File.open(self[:crl_serial_file], 'r') do |old|
        if old.flock(File::LOCK_EX)
          mode = begin
                   File::Stat.new(self[:crl_serial_file]) & 0o666
                 rescue
                   0o644
                 end

          crlnum = begin
                     old.gets.scan(%r{\d+}) { |num| break Integer(num) }
                   rescue
                     0
                   end

          crlnum += 1

          # Create new serial file with a temporary name
          new = Tempfile.create(File.basename(self[:crl_serial_file]), File.dirname(self[:crl_serial_file]))

          new.puts '0%d' % [ crlnum ]

          # Use file permissions from the original file
          new.chmod(mode)
          new.close

          # Make it the new serial file
          File.rename(new.path, self[:crl_serial_file])

          crl.add_extension(OpenSSL::X509::Extension.new('crlNumber', OpenSSL::ASN1::Integer(crlnum)))
        end
      end

      # Read CA database
      PuppetX::OpenSSL::CADB.read(self[:ca_database_file]) do |file|
        file.each do |line|
          next unless (match = line.match(PuppetX::OpenSSL::CADB::DB_LINE_FORMAT))

          status, _expired, revoked, serial, _certfile, _subject = match.captures

          next unless status == PuppetX::OpenSSL::CADB::REVOKED

          rev = OpenSSL::X509::Revoked.new
          rev.serial = (OpenSSL::BN.new(Integer(serial, 16)))

          # Parse time of revocation
          rev.time = case revoked.length
                     when 13
                       Time.strptime(revoked, '%y%m%d%H%M%SZ')
                     when 15
                       Time.strptime(revoked, '%Y%m%d%H%M%SZ')
                     else
                       Time.now
                     end

          crl.add_revoked(rev)
        end
      end

      # Sign the certificate using the CA key
      crl.sign issuer_key, OpenSSL::Digest.new(self[:signature_algorithm].to_s)

      @generated_content = crl.to_pem
    end

    @generated_content
  end

  def generate
    opts = {
      ensure: (self[:ensure] == :absent) ? :absent : :file
    }

    [:path,
     :owner,
     :group,
     :mode,
     :backup,
     :selinux_ignore_defaults,
     :selrange,
     :selrole,
     :seltype,
     :seluser,
     :show_diff].each do |param|
      opts[param] = self[param] unless self[param].nil?
    end

    excluded_metaparams = [:before, :notify, :require, :subscribe]

    Puppet::Type.metaparams.each do |metaparam|
      opts[metaparam] = self[metaparam] unless self[metaparam].nil? || excluded_metaparams.include?(metaparam)
    end

    [Puppet::Type.type(:file).new(opts)]
  end

  def eval_generate
    generate = if self[:ensure] == :absent
                 false
               elsif File.file?(self[:path])
                 # Check file content
                 regex = Regexp.new('^-+BEGIN X509 CRL-+$').freeze
                 File.open(self[:path]).each_line.none? { |x| x.match?(regex) }
               else
                 true
               end

    # define/replace content
    catalog.resource("File[#{self[:path]}]")[:content] = content if generate

    [catalog.resource("File[#{self[:path]}]")]
  end

  def refresh
    catalog.resource("File[#{self[:path]}]")[:content] = content if self[:ensure] == :present
  end
end
