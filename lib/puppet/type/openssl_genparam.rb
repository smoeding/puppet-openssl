# openssl_genparam.rb --- Generate openssl parameter files

Puppet::Type.newtype(:openssl_genparam) do
  @doc = <<-DOC
    @summary Generate Diffie-Hellman or Elliptic Curve parameter file

    The type is refreshable. The `openssl_genaram` type will regenerate the
    parameters if the resource is notified from another resource.

    @example Create a Diffie-Hellman parameter file using 2048 bits

      openssl_genparam { '/tmp/dhparam.pem':
        algorithm => 'DH',
        bits      => '2048,
        generator => '2',
      }

    @example Create an Elliptic Curve parameter file using the secp521e1 curve

      openssl_genparam { '/tmp/ecparam.pem':
        algorithm => 'EC',
        curve     => 'secp521r1',
      }

    @example Automatically refresh a parameter file every 3 months

      openssl_genparam { '/tmp/dhparam.pem':
        algorithm        => 'DH',
        bits             => '2048,
        generator        => '2',
        refresh_interval => '3mo',
      }

    @example Refresh a parameter file if another file changes

      openssl_genparam { '/tmp/dhparam.pem':
        algorithm => 'DH',
        bits      => '2048,
        subscribe => File['/etc/ssl/parameters.trigger'],
      }
  DOC

  def munge_interval(value)
    return nil if value.nil?

    %r{^([0-9]+)(y|mo|w|d|h|mi|s)?$}.match(value) do |match|
      time, unit = match.captures
      case unit
      when 'y'
        time.to_i * 365 * 24 * 60 * 60
      when 'mo'
        time.to_i * 30 * 24 * 60 * 60
      when 'w'
        time.to_i * 7 * 24 * 60 * 60
      when 'd'
        time.to_i * 24 * 60 * 60
      when 'h'
        time.to_i * 60 * 60
      when 'mi'
        time.to_i * 60
      else
        time.to_i
      end
    end
  end

  ensurable

  newparam(:file, namevar: true) do
    desc 'The name of the parameter file to manage.'

    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  newparam(:algorithm) do
    desc 'The algorithm to generate the parameters for.'

    newvalues 'DH', 'EC'
    munge { |value| value.to_s }

    validate do |value|
      raise Puppet::Error, 'Parameter algorithm is mandatory' if value.nil?
    end
  end

  newparam(:bits) do
    desc 'The number of bits to use for Diffie-Hellman parameters.'

    newvalues '2048', '4096', '8192'
    munge { |value| value.to_s }
  end

  newparam(:generator) do
    desc 'The generator to use for Diffie-Hellman parameters.'

    newvalues '2', '5'
    munge { |value| value.to_s }
  end

  newparam(:curve) do
    desc 'The name of the curve to use for Elliptic Curve parameters.'

    newvalues %r{^[a-zA-Z][a-zA-Z0-9-]+[0-9]$}
    munge { |value| value.to_s }
  end

  newparam(:refresh_interval) do
    desc 'The Refresh interval for the parameter file. A new parameter file
      will be generated after this time.

      The value must be a number optionally followed by a time unit. The
      following units are understood: `y` for year (365 days), `mo` for
      months (30 days), `w` for week (7 days), `d` for days (24 hours), `h`
      for hours (60 minutes), `mi` for minute (60 seconds). When the unit `s`
      or no unit is used then the value is interpreted as the number of
      seconds.'

    newvalues %r{^[0-9]+(y|mo|w|d|h|mi|s)?$}
    munge { |value| @resource.munge_interval(value) }
  end

  validate do
    case self[:algorithm]
    when 'DH'
      raise Puppet::Error, 'Parameter bits is mandatory for Diffie-Hellman parameters' if self[:bits].nil?
      raise Puppet::Error, 'Parameter generator is mandatory for Diffie-Hellman parameters' if self[:generator].nil?
    when 'EC'
      raise Puppet::Error, 'Parameter curve is mandatory for Elliptic Curve parameters' if self[:curve].nil?
    else
      raise Puppet::Error, "Unsupported algorithm #{self[:algorithm]}"
    end
  end

  def refresh
    provider.refresh if self[:ensure] == :present
  end
end
