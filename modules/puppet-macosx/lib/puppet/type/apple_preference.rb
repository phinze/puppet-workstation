Puppet::Type.newtype(:apple_preference) do
  @doc = "Manages OS X preferences"
  ensurable

  newparam(:name) do
      desc "The name of the setting."
  end 

  newparam(:domain) do
    desc "The preference domain. User defaults belong to domains, which typically correspond to individual applications. Each domain has a dictionary of keys and values representing its defaults."

    validate do |value|
      unless value =~ /^[a-zA-Z0-9.\/~]+/
        raise ArgumentError, "%s is not a valid domain" % value
      end
    end
  end

  newparam(:key) do
    desc "The key for this preference, always a string"

    validate do |value|
      #pass
    end
  end

  newparam(:value) do
    desc "The value for this preference"

    validate do |value|
      unless [true,false].include?(value) || value  =~ /^[(){}=;a-zA-Z0-9.]+/
        raise ArgumentError , "%s is not a valid value" % value
      end
    end
  end

  newparam(:type) do
    desc "The datatype for this preference"
    newvalues(:string, :data, :int, :float, :bool, :date, :array)
    defaultto :string
  end
end
