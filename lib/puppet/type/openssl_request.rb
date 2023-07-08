# frozen_string_literal: true

require 'openssl'
require 'puppet/type/file/owner'
require 'puppet/type/file/group'
require 'puppet/type/file/mode'

Puppet::Type.newtype(:openssl_request) do
  desc <<-DOC
    @summary Create and maintain an OpenSSL Certificate Signing Request

    **This type is still beta!**

    The type creates a X.509 Certificate Signing Request (CSR) which can
    either be submitted to a Certificate Authority (CA) for signing or used
    to create a self-signed certificate. Both operations can also be
    performed using the `openssl_cert` type.

    The X.509 subject of the request can be defined by using the
    `common_name`, `domain_component`, `organization_unit_name`,
    `organization_name`, `locality_name`, `state_or_province_name`,
    `country_name` and `email_address` parameters. Setting a Common Name is
    mandatory and the host fully-qualified domain name (FQDN) is commonly
    used for node or service certificates.

    The request can also include the following extensions by setting the
    appropriate type parameters: `basicConstraints`, `keyUsage`,
    `extendedKeyUsage` and `subjectAltName`.

    The type expects to find the "-----BEGIN CERTIFICATE REQUEST-----" token
    in the first line of the file or it will overwrite the file content with
    new parameters.

    The type is refreshable and will generate a new request if the resource
    is notified from another resource.

    This type uses the Ruby OpenSSL library and does not run the `openssl`
    binary provided by the operating system.

    **Autorequires:** If Puppet is managing the OpenSSL key that is used to
    create the CSR, the `openssl_request` resource will autorequire that key.

    @example Generate CSR to be used for a new private Certificate Authority

      openssl_request { '/etc/ssl/ca.csr':
        key              => '/etc/ssl/ca.key',
        common_name      => 'ACME Root CA',
        domain_component => [ 'ACME', 'US' ],
      }

    @example Generate CSR for a web application

      openssl_request { "/etc/ssl/app.example.com.csr":
        key                         => '/etc/ssl/app.example.com.key',
        common_name                 => 'app.example.com',
        key_usage                   => ['keyEncipherment', 'digitalSignature'],
        extended_key_usage          => ['serverAuth', 'clientAuth'],
        subject_alternate_names_dns => ['app.example.com'],
        subject_alternate_names_ip  => ['192.0.2.42'],
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

  newparam(:common_name) do
    desc <<-DOC
      The value of the X.509 common name (CN) attribute.
    DOC
  end

  newparam(:domain_component, array_matching: :all) do
    desc <<-DOC
      The value of the X.509 domain component (DC) attributes. The value
      should be an array. The items are used in the same order, so for
      example the value `['example', 'com']` should be used to create
      the attribute `DC=example, DC=com` in the request.
    DOC

    munge { |value| Array(value) }
  end

  newparam(:organization_unit_name) do
    desc <<-DOC
      The value of the X.509 organization unit name (OU) attribute.
    DOC
  end

  newparam(:organization_name) do
    desc <<-DOC
      The value of the X.509 organization name (O) attribute.
    DOC
  end

  newparam(:locality_name) do
    desc <<-DOC
      The value of the X.509 locality name (L) attribute.
    DOC
  end

  newparam(:state_or_province_name) do
    desc <<-DOC
      The value of the X.509 state or province name (ST) attribute.
    DOC
  end

  newparam(:country_name) do
    desc <<-DOC
      The value of the X.509 country (C) attribute.
    DOC
  end

  newparam(:email_address) do
    desc <<-DOC
      The value of the X.509 emailAddress attribute.
    DOC
  end

  newparam(:key_usage, array_matching: :all) do
    desc <<-DOC
      The X.509v3 Key Usage extension.
    DOC

    validate do |value|
      value.all? do |item|
        [:digitalSignature, :nonRepudiation, :keyEncipherment,
         :dataEncipherment, :keyAgreement, :keyCertSign, :cRLSign,
         :encipherOnly, :decipherOnly].include? item
      end
    end
  end

  newparam(:key_usage_critical, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc <<-DOC
      Whether the Key Usage extension should be critical.
    DOC

    newvalues true, false
  end

  newparam(:extended_key_usage, array_matching: :all) do
    desc <<-DOC
      The X.509v3 Extended Key Usage extension.
    DOC

    validate do |value|
      value.all? do |item|
        [:serverAuth, :clientAuth, :codeSigning, :emailProtection,
         :timeStamping, :OCSPSigning, :ipsecIKE, :msCodeInd, :msCodeCom,
         :msCTLSign, :msEFS].include? item
      end
    end
  end

  newparam(:extended_key_usage_critical, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc <<-DOC
      Whether the Extenden Key Usage extension should be critical.
    DOC

    newvalues true, false
  end

  newparam(:basic_constraints_ca, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc <<-DOC
      Whether the Basic Constraints CA extension should be set.
    DOC

    newvalues true, false
  end

  newparam(:basic_constraints_ca_critical, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc <<-DOC
      Whether the Basic Constraints CA extension should be critical.
    DOC

    newvalues true, false
  end

  newparam(:subject_alternate_names_dns, array_matching: :all) do
    desc <<-DOC
      An array of DNS names that will be added as subject alternate names.
    DOC

    munge { |value| Array(value) }
  end

  newparam(:subject_alternate_names_ip, array_matching: :all) do
    desc <<-DOC
      An array of IP addresses that will be added as subject alternate names.
    DOC

    munge { |value| Array(value) }
  end

  newparam(:key) do
    desc <<-DOC
      The path to the key file to use when creating the certificate request.
    DOC

    validate do |value|
      unless Puppet::Util.absolute_path?(value, :posix) || Puppet::Util.absolute_path?(value, :windows)
        raise ArgumentError, _("Key file paths must be fully qualified, not '%{_value}'") % { _value: value }
      end
    end
  end

  newparam(:key_password) do
    desc <<-DOC
      The password to use when loading a protected key.
    DOC

    # The empty string disables the interactive password prompt
    defaultto ''
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

  autorequire(:file) do
    [self[:path]]
  end

  autorequire(:openssl_key) do
    [self[:key]]
  end

  def validate
    raise ArgumentError, "Attribute 'key' is mandatory" if self[:key].nil?
    raise ArgumentError, "Attribute 'common_name' is mandatory" if self[:common_name].nil?
  end

  def exists?
    self[:ensure] == :present
  end

  def content
    unless @generated_content
      # Generate certificate request
      req = OpenSSL::X509::Request.new
      req.version = 0

      # Read the key from the file; this could be a RSA or EC key
      pem = File.open(self[:key])

      begin
        key = OpenSSL::PKey.read pem, self[:key_password]
      rescue
        raise Puppet::Error, 'Unable to load key (missing password?)'
      end

      # Add public key from the key to the request.
      # Observe the different ways to use the EC and RSA keys.
      req.public_key = if key.is_a? OpenSSL::PKey::EC
                         key
                       else
                         key.public_key
                       end

      # Add X.509 subject
      subject = [['CN', self[:common_name].to_s, OpenSSL::ASN1::UTF8STRING]]

      self[:domain_component]&.each do |dc|
        subject << ['DC', dc.to_s, OpenSSL::ASN1::IA5STRING]
      end

      if self[:organization_unit_name]
        subject << ['OU', self[:organization_unit_name].to_s, OpenSSL::ASN1::UTF8STRING]
      end

      if self[:organization_name]
        subject << ['O', self[:organization_name].to_s, OpenSSL::ASN1::UTF8STRING]
      end

      if self[:locality_name]
        subject << ['L', self[:locality_name].to_s, OpenSSL::ASN1::UTF8STRING]
      end

      if self[:state_or_province_name]
        subject << ['ST', self[:state_or_province_name].to_s, OpenSSL::ASN1::UTF8STRING]
      end

      if self[:country_name]
        subject << ['C', self[:country_name].to_s, OpenSSL::ASN1::PRINTABLESTRING]
      end

      if self[:email_address]
        subject << ['emailAddress', self[:email_address].to_s, OpenSSL::ASN1::IA5STRING]
      end

      req.subject = OpenSSL::X509::Name.new subject

      # Add request extensions
      extfactory = OpenSSL::X509::ExtensionFactory.new
      extensions = []

      unless self[:basic_constraints_ca].nil?
        extensions << extfactory.create_ext('basicConstraints',
                                            'CA:' + self[:basic_constraints_ca].to_s.upcase,
                                            critical(:basic_constraints_ca_critical))
      end

      unless self[:key_usage].nil?
        extensions << extfactory.create_ext('keyUsage',
                                            self[:key_usage].join(','),
                                            critical(:key_usage_critical))
      end

      unless self[:extended_key_usage].nil?
        extensions << extfactory.create_ext('extendedKeyUsage',
                                            self[:extended_key_usage].join(','),
                                            critical(:extended_key_usage_critical))
      end

      san = []

      unless self[:subject_alternate_names_dns].nil?
        san << self[:subject_alternate_names_dns].uniq.map { |x| "DNS:#{x}" }
      end

      unless self[:subject_alternate_names_ip].nil?
        san << self[:subject_alternate_names_ip].uniq.map { |x| "IP:#{x}" }
      end

      unless san.empty?
        extensions << extfactory.create_ext('subjectAltName', san.join(','))
      end

      # Add extenstions as extReq attribute
      unless extensions.empty?
        attr = OpenSSL::ASN1::Set.new([OpenSSL::ASN1::Sequence.new(extensions)])
        req.add_attribute OpenSSL::X509::Attribute.new('extReq', attr)
      end

      # Add digest
      req.sign key, OpenSSL::Digest.new(self[:signature_algorithm].to_s)

      @generated_content = req.to_pem
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
                 regex = Regexp.new('^-+BEGIN CERTIFICATE REQUEST-+$').freeze
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

  private

  def critical(flag)
    case self[flag]
    when :true, true
      true
    when :false, false
      false
    else
      nil
    end
  end
end
