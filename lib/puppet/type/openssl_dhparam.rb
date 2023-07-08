# frozen_string_literal: true

require 'openssl'
require 'puppet/type/file/owner'
require 'puppet/type/file/group'
require 'puppet/type/file/mode'

Puppet::Type.newtype(:openssl_dhparam) do
  @doc = <<-DOC
    @summary Generate a file with Diffie-Hellman parameters

    **This type is still beta!**

    Generate Diffie-Hellman parameters for an TLS enabled application by
    specifying the number of bits and the generator number to use.

    The type expects to find the "-----BEGIN DH PARAMETERS-----" token in the
    first line of the file or it will overwrite the file content with new
    parameters.

    The type is refreshable and will generate new parameters if the resource
    is notified from another resource.

    This type uses the Ruby OpenSSL library and does not run the `openssl`
    binary provided by the operating system.

    *Note*: The creation of Diffie-Hellman parameters with a larger number of
    bits takes a significant amount of CPU time (sometimes multiple
    minutes). This might look as if the Puppet Agent is hanging.

    @example Generate Diffie-Hellman parameter file

      openssl_dhparam { '/etc/postfix/dh2048.pem':
        owner   => 'root',      # Optional. Default to undef
        group   => 'root',      # Optional. Default to undef
        mode    => '0644'       # Optional. Default to undef
        require => Package['postfix'],
        notify  => Service['postfix'],
      }

    @example Trigger refresh using another resource

      openssl_dhparam { '/etc/postfix/dh2048.pem':
        subscribe => Package['postfix'],
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

  newparam(:bits) do
    desc <<-DOC
      The number of bits for the Diffie-Hellman parameters.
    DOC

    munge { |value| value.to_i }

    defaultto 2048
    newvalues(1024, 2048, 3072, 4096, 5120, 6144, 7168, 8192)
  end

  newparam(:generator) do
    desc <<-DOC
      The generator number for the Diffie-Hellman parameters.
    DOC

    munge { |value| value.to_i }

    defaultto 2
    newvalues(2, 5)
  end

  autorequire(:file) do
    [self[:path]]
  end

  def exists?
    self[:ensure] == :present
  end

  def content
    unless @generated_content
      dh = loop do
        Puppet.notice("#{self}: generating DH parameters with #{self[:bits]} bits")
        dh = OpenSSL::PKey::DH.new(self[:bits], self[:generator])
        break dh if dh.params_ok?
      end

      @generated_content = dh.to_pem
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
                 regex = Regexp.new('^-+BEGIN DH PARAMETERS-+$').freeze
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
