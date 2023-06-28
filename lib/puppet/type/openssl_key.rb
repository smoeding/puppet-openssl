# frozen_string_literal: true

require 'openssl'
require 'puppet/type/file/owner'
require 'puppet/type/file/group'
require 'puppet/type/file/mode'

Puppet::Type.newtype(:openssl_key) do
  desc <<-DOC
    @summary Create an OpenSSL private key

    **This type is still beta!**

    This type creates RSA or Elliptic Curve keys depending on the parameter
    `algorithm`.

    The type expects to find the "-----BEGIN PRIVATE KEY-----" token in the
    first line of the file or it will overwrite the file content with a new
    key.

    The key can optionally be encrypted using a supplied password.

    This type uses the Ruby OpenSSL library and does not run the `openssl`
    binary provided by the operating system.

    The type is refreshable and will generate a new key if the resource is
    notified from another resource.

    @example Generate a 2048 bit RSA key

      openssl_key { '/etc/ssl/rsa-2048.key':
        algorithm => 'RSA',
        bits      => 2048,
      }

    @example Generate an Elliptic Curve key that is encrypted using AES128

      openssl_key { '/etc/ssl/ec-secp256k1.key':
        algorithm => 'EC',
        curve     => 'secp256k1',
        cipher    => 'aes128',
        password  => 'rosebud',
      }

    @example Create a key and regenerate it if another resource changes

      openssl_key { '/etc/ssl/rsa-2048.key':
        algorithm => 'RSA',
        bits      => 2048,
        subscribe => File['/etc/ssl/key.trigger'],
      }
  DOC

  ensurable

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

  newparam(:force, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc <<-DOC
      Specifies whether to merge data structures, keeping the values with
      higher order.
    DOC

    defaultto false
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

  newparam(:algorithm) do
    desc <<-DOC
      The algorithm to use when generating a private key. The number of bits
      must be supplied if an RSA key is generated. For an EC key the curve
      name must be given.
    DOC

    defaultto :RSA
    newvalues(:RSA, :EC)
  end

  newparam(:bits) do
    desc <<-DOC
      The number of bits for the RSA key. This parameter is mandatory for RSA
      keys. Keys with 1024 bits should only be used for specific applications
      like DKIM.
    DOC

    munge { |value| value.to_i }

    defaultto 2048
    newvalues(1024, 2048, 3072, 4096, 5120, 6144, 7168, 8192)
  end

  newparam(:curve) do
    desc <<-DOC
      The curve to use for elliptic curve key. This parameter is mandatory
      for EC keys. Consult your OpenSSL documentation to find out what curves
      are supported on your system. The following curves should be available
      for TLS 1.3 and earlier: `secp256r1`, `secp384r1`, `secp521r1`.
    DOC

    defaultto :secp384r1

    validate do |value|
      unless OpenSSL::PKey::EC.builtin_curves.to_h.keys.include? value.to_s
        raise ArgumentError, "Curve '#{value}' is not supported by OpenSSL"
      end
    end
  end

  newparam(:cipher) do
    desc <<-DOC
      Encrypt the key with the supplied cipher. A password must be given if
      this parameter is set.
    DOC

    validate do |value|
      unless OpenSSL::Cipher.ciphers.include? value.to_s
        raise ArgumentError, "Cipher '#{value}' is not supported by OpenSSL"
      end
    end
  end

  newparam(:password) do
    desc <<-DOC
      Use the supplied password to encrypt the key. Setting only a password
      without a cipher creates an unprotected key.
    DOC
  end

  validate do
    case self[:algorithm]
    when :RSA
      raise ArgumentError, "Parameter 'bits' is mandatory for RSA keys" if self[:bits].nil?
    when :EC
      raise ArgumentError, "Parameter 'curve' is mandatory for EC keys" if self[:curve].nil?
    end

    if !self[:cipher].nil? && self[:password].nil?
      raise ArgumentError, 'A password must be given when encryption is used.'
    end
  end

  autorequire(:file) do
    [self[:path]]
  end

  def exists?
    self[:ensure] == :present
  end

  def content
    unless @generated_content
      key = case self[:algorithm]
            when :RSA
              OpenSSL::PKey::RSA.generate self[:bits].to_i
            when :EC
              OpenSSL::PKey::EC.generate self[:curve].to_s
            end

      pem = if self[:cipher] && self[:password]
              cipher = OpenSSL::Cipher::Cipher.new self[:cipher].to_s
              key.to_pem cipher, self[:password].to_s
            else
              key.to_pem
            end

      @generated_content = pem
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
    generate = if File.file?(self[:path])
                 # Check file content
                 regex = Regexp.new('^-+BEGIN.+PRIVATE KEY-+$').freeze
                 line1 = File.open(self[:path], &:readline)

                 !regex.match?(line1)
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
