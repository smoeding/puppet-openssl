# frozen_string_literal: true

require 'openssl'
require 'puppet/type/file/owner'
require 'puppet/type/file/group'
require 'puppet/type/file/mode'

Puppet::Type.newtype(:openssl_cert) do
  desc <<-DOC
    @summary Create an OpenSSL certificate from a Certificate Signing Request

    **This type is still beta!**

    The type takes a Certificate Signing Request (create by `openssl_request`
    for example) and an issuer certificate and key as input to generate
    a signed certificate.

    To create a self-signed certificate, set `issuer_key` to the same key
    that was used to create the request. Otherwise `issuer_cert` and
    `issuer_key` should point to your CA certificate and key.

    The type uses a random 128 bit number as serial number.

    The certificate validity starts the moment the certificate is signed and
    terminates as defined by the parameter `days`. The expiration time of the
    cerificate is additionally limited by the validity of your CA certificate
    unless you create a self-signed.

    The parameters `copy_request_extensions` and `omit_request_extensions`
    can be used to specifically allow or deny some extensions from the
    request. You can also use parameters to set extensions to a fixed value.

    The type expects to find the "-----BEGIN CERTIFICATE-----" token in the
    file or it will overwrite the file content with a new certificate.

    The type is refreshable and will generate a new certificate if the
    resource is notified from another resource.

    This type uses the Ruby OpenSSL library and does not run the `openssl`
    binary provided by the operating system.

    **Autorequires:** If Puppet is managing the OpenSSL issuer key, issuer
    certificate or request that is used to create the certificate, the
    `openssl_cert` resource will autorequire these resources

    @example Create CA certificate from a CSR using the specified extensions

      openssl_cert { '/etc/ssl/ca.crt':
        request                       => '/etc/ssl/ca.csr',
        issuer_key                    => '/etc/ssl/ca.key',
        key_usage                     => ['keyCertSign', 'cRLSign'],
        key_usage_critical            => true,
        basic_constraints_ca          => true,
        basic_constraints_ca_critical => true,
        subject_key_identifier        => 'hash',
        authority_key_identifier      => ['issuer', 'keyid:always'],
        days                          => 2922,
      }

    @example Create certificate for a node and copy two extensions from the CSR

      openssl_cert { "/etc/ssl/${facts[networking][fqdn]}.crt":
        request                  => "/etc/ssl/${facts[networking][fqdn]}.csr",
        issuer_key               => '/etc/ssl/ca.key',
        issuer_cert              => '/etc/ssl/ca.crt',
        subject_key_identifier   => 'hash',
        authority_key_identifier => ['keyid', 'issuer'],
        copy_request_extensions  => ['subjectAltName', 'keyUsage'],
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

  newparam(:request) do
    desc <<-DOC
      The path to the certificate request to use when creating the certificate.
    DOC

    validate do |value|
      unless Puppet::Util.absolute_path? value
        raise ArgumentError, "Invalid certificate request file path #{value}"
      end
    end
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
      The path to the key file that is used to issue the certificate. If this
      is the same key that was used to create the request, then a self-signed
      certificate will be created.
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
      The number of days that the certificate should be valid.

      A certificate can't be valid after the issuing certificate has
      expired. So the validity is limited by the expiration time of the
      issuing certificate.
    DOC

    munge { |value| value.to_i }

    defaultto 365
    newvalues %r{^[0-9]+$}
  end

  newparam(:key_usage, array_matching: :all) do
    desc <<-DOC
      The X.509v3 Key Usage extension. Valid options: `digitalSignature`,
      `nonRepudiation`, `keyEncipherment`, `dataEncipherment`,
      `keyAgreement`, `keyCertSign`, `cRLSign`, `encipherOnly`,
      `decipherOnly`.

      Setting this parameter overrides the value of the `keyUsage` extension
      from the request.
    DOC

    validate do |value|
      value.all? do |item|
        [:digitalSignature, :nonRepudiation, :keyEncipherment,
         :dataEncipherment, :keyAgreement, :keyCertSign, :cRLSign,
         :encipherOnly, :decipherOnly].include? item
      end
    end
  end

  newparam(:key_usage_critical) do
    desc <<-DOC
      Whether the Key Usage extension should be critical.
    DOC

    newvalues :true, :false
  end

  newparam(:extended_key_usage, array_matching: :all) do
    desc <<-DOC
      The X.509v3 Extended Key Usage extension. Valid options: `serverAuth`,
      `clientAuth`, `codeSigning`, `emailProtection`, `timeStamping`,
      `OCSPSigning`, `ipsecIKE`, `msCodeInd`, `msCodeCom`, `msCTLSign`,
      `msEFS`.

      Setting this parameter overrides the value of the `extendedKeyUsage`
      extension from the request.
    DOC

    validate do |value|
      value.all? do |item|
        [:serverAuth, :clientAuth, :codeSigning, :emailProtection,
         :timeStamping, :OCSPSigning, :ipsecIKE, :msCodeInd, :msCodeCom,
         :msCTLSign, :msEFS].include? item
      end
    end
  end

  newparam(:extended_key_usage_critical) do
    desc <<-DOC
      Whether the Extenden Key Usage extension should be critical.
    DOC

    newvalues :true, :false
  end

  newparam(:basic_constraints_ca) do
    desc <<-DOC
      Whether the Basic Constraints CA extension should be set.

      Setting this parameter overrides the value of the `basicConstraints`
      extension from the request.
    DOC

    newvalues :true, :false
  end

  newparam(:basic_constraints_ca_critical) do
    desc <<-DOC
      Whether the Basic Constraints CA extension should be critical.
    DOC

    newvalues :true, :false
  end

  newparam(:subject_key_identifier) do
    desc <<-DOC
      The Subject Key Identifier extension. Normally the value `hash` is used
      when creating certificates.
    DOC
  end

  newparam(:subject_key_identifier_critical) do
    desc <<-DOC
      Whether the Subject Key Identifier extension should be critical.
    DOC

    newvalues :true, :false
  end

  newparam(:authority_key_identifier, array_matching: :all) do
    desc <<-DOC
      The Authority Key Identifier extension.
    DOC

    validate do |value|
      value.all? do |item|
        ['keyid', 'issuer', 'keyid:always', 'issuer:always'].include? item
      end
    end
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

  newparam(:copy_request_extensions, array_matching: :all) do
    desc <<-DOC
      List of extensions to copy from the certificate request. If this
      parameter is set, then only these extensions are copied from the
      request into the final certificate. Otherwise all extensions are copied
      from the request unless the parameter `omit_request_extensions`
      disallows them.

      Some extension names that might be useful to include here are
      `basicConstraints`, `keyUsage`, `extendedKeyUsage`, `subjectAltName`.

      If an extension name is included in `copy_request_extension` and
      `omit_request_extensions`, then `omit_request_extensions` has
      precedence and the extension is not copied from the request to the
      final certificate.

      Extensions defined by explicit type parameters always override
      extensions from the request.
    DOC

    defaultto []
  end

  newparam(:omit_request_extensions, array_matching: :all) do
    desc <<-DOC
      List of extensions to omit from the certificate request. If this
      parameter is set, then the named extensions are never copied from the
      request into the final certificate. Otherwise all extensions are copied
      from the request unless the parameter `copy_request_extensions`
      restricts them.

      Some extension names that might be useful to include here are
      `basicConstraints`, `keyUsage`, `extendedKeyUsage`, `subjectAltName`.

      If an extension name is include in `copy_request_extension` and
      `omit_request_extensions`, then `omit_request_extensions` has
      precedence and the extension is not copied from the request to the
      final certificate.

      Extensions defined by explicit type parameters always override
      extensions from the request.
    DOC

    defaultto []
  end

  autorequire(:file) do
    [self[:path]]
  end

  autorequire(:openssl_request) do
    [self[:request]]
  end

  autorequire(:openssl_key) do
    [self[:issuer_key]]
  end

  autorequire(:openssl_cert) do
    [self[:issuer_cert]] unless self[:issuer_cert].nil?
  end

  def validate
    if self[:authority_key_identifier]
      if self[:subject_key_identifier].nil?
        raise ArgumentError, "Parameter 'subject_key_identifier' must be set if 'authority_key_identifier' is used"
      end

      if self[:authority_key_identifier].count { |x| x.match(%r{^keyid}) } > 1
        raise ArgumentError, "Parameter 'authority_key_identifier' has multiple keyid values"
      end

      if self[:authority_key_identifier].count { |x| x.match(%r{^issuer}) } > 1
        raise ArgumentError, "Parameter 'authority_key_identifier' has multiple issuer values"
      end
    end

    raise ArgumentError, "Parameter 'request' is mandatory" if self[:request].nil?
    raise ArgumentError, "Parameter 'issuer_key' is mandatory" if self[:issuer_key].nil?
  end

  def exists?
    self[:ensure] == :present
  end

  def content
    unless @generated_content
      # Read and validate request
      req = OpenSSL::X509::Request.new File.open(self[:request])

      raise ArgumentError, 'Request signature is invalid' unless req.verify req.public_key

      # Read and validate private key
      pem = File.open(self[:issuer_key])

      begin
        issuer_key = OpenSSL::PKey.read pem, self[:issuer_key_password]
      rescue
        raise Puppet::Error, 'Unable to load key (missing password?)'
      end

      selfsigned = if req.public_key.public_key.class == issuer_key.public_key.class
                     case issuer_key.public_key
                     when OpenSSL::PKey::RSA
                       issuer_key.public_key.to_s == req.public_key.to_s
                     when OpenSSL::PKey::EC::Point
                       issuer_key.public_key.to_bn == req.public_key.public_key.to_bn
                     else
                       false
                     end
                   else
                     false
                   end

      # Create new certificate
      crt = OpenSSL::X509::Certificate.new
      crt.version = 2

      # Set Subject from request
      crt.subject = req.subject
      crt.public_key = req.public_key

      # Issuer
      if selfsigned
        issuer = crt
        crt.issuer = req.subject
        Puppet.notice("#{self} issuing self-signed certificate for #{crt.issuer}")
      else
        issuer = OpenSSL::X509::Certificate.new File.open(self[:issuer_cert])
        crt.issuer = issuer.subject
        Puppet.notice("#{self} issuing certificate from #{crt.issuer}")
      end

      # Generate 128 bit serial number
      bit128 = OpenSSL::Random.random_bytes 16
      qwords = bit128.unpack('Q>*')

      # In case a colon-separated representation is needed in the future
      # serial = bit128.unpack('C*').map { |x| '%02x' % x}.join(':')

      crt.serial = (OpenSSL::BN.new(qwords[0]) << 64) + OpenSSL::BN.new(qwords[1])

      # Validity
      crt.not_before = Time.now
      crt.not_after = Time.now + (86_400 * self[:days])

      # Limit validity to the expiration time of the issuing certificate
      if issuer.not_after && (issuer.not_after < crt.not_after)
        crt.not_after = issuer.not_after
        Puppet.notice("#{self} expiration time of certificate is limited to #{crt.not_after} by issuing certificate")
      end

      # Extensions
      extensions = {}

      extfactory = OpenSSL::X509::ExtensionFactory.new
      extfactory.subject_certificate = crt
      extfactory.issuer_certificate = issuer

      # Parse request extensions
      req.attributes.each do |attr|
        next unless (attr.oid == 'extReq') && (attr.value.is_a? OpenSSL::ASN1::Set)

        attr.value.each do |seq|
          next unless seq.is_a? OpenSSL::ASN1::Sequence

          # Create copy from request extensions using the DER encoded extension
          seq.each do |obj|
            ext = OpenSSL::X509::Extension.new obj.to_der
            extensions[ext.oid] = ext
          end
        end
      end

      # Filter extensions
      extensions.delete_if do |key, _|
        if !self[:copy_request_extensions].include? key
          # Remove the extension if we have an array of permitted extensions
          # and the extension is not included in that array.
          true
        elsif self[:omit_request_extensions].include? key
          # Remove the extension if we have an array of disallowed extensions
          # and the extension is included in that array.
          true
        else
          # Allow the extension otherwise.
          false
        end
      end

      unless self[:basic_constraints_ca].nil?
        ext = extfactory.create_ext('basicConstraints',
                                    'CA:' + self[:basic_constraints_ca].to_s.upcase,
                                    critical(:basic_constraints_ca_critical))
        extensions[ext.oid] = ext
      end

      unless self[:key_usage].nil? || self[:key_usage].empty?
        ext = extfactory.create_ext('keyUsage',
                                    self[:key_usage].join(','),
                                    critical(:key_usage_critical))
        extensions[ext.oid] = ext
      end

      unless self[:extended_key_usage].nil? || self[:extended_key_usage].empty?
        ext = extfactory.create_ext('extendedKeyUsage',
                                    self[:extended_key_usage].join(','),
                                    critical(:extended_key_usage_critical))
        extensions[ext.oid] = ext
      end

      # Add all defined extensions to the certificate
      extensions.each_value { |x| crt.add_extension x }

      # Subject Key Identifier
      unless self[:subject_key_identifier].nil?
        crt.add_extension extfactory.create_extension('subjectKeyIdentifier',
                                                      self[:subject_key_identifier])
      end

      # Authority Key Identifier (must come after the Subject Key Identifier)
      unless self[:authority_key_identifier].nil? || self[:authority_key_identifier].empty?
        crt.add_extension extfactory.create_extension('authorityKeyIdentifier',
                                                      self[:authority_key_identifier].join(','))
      end

      # Sign the certificate using the CA key
      crt.sign issuer_key, OpenSSL::Digest.new(self[:signature_algorithm].to_s)

      @generated_content = crt.to_pem
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
                 regex = Regexp.new('^-+BEGIN CERTIFICATE-+$').freeze
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
