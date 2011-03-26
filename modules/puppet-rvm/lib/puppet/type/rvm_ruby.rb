Puppet::Type.newtype(:rvm_ruby) do
  @doc = "Manages rvm rubies"
  ensurable

  newparam(:name) do
    desc "the name of the ruby to install"
  end

  newparam(:default_ruby) do
    desc "Whether this ruby should be set as default"

    validate do |value|
      unless [true,false].include?(value)
        raise ArgumentError , "%s is not a valid value" % value
      end
    end
    defaultto(false)
  end
end
