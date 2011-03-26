Puppet::Type.type(:rvm_ruby).provide(:rvm) do
  desc 'Uses `rvm` command to manage rubies'

  defaultfor :operatingsystem => :darwin

  commands :rvm => "rvm"

  def create
    rvm "install", resource[:name]
    if resource[:default]
      rvm "--default", "use", resource[:name]
    end
  end

  def destroy
    rvm "remove", resource[:name]
  end

  def exists?
    value = rvm "list", "rubies"
    value.include?(resource[:name])
  end
end
