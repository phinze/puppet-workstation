Puppet::Type.type(:apple_preference).provide(:defaults) do
  desc 'Uses OSX `defaults` command to support apple preferences'

  confine :operatingsystem => :darwin
  defaultfor :operatingsystem => :darwin

  commands :defaults => "/usr/bin/defaults"

  def create
    defaults "write", resource[:domain], resource[:key], "-#{resource[:type]}", resource[:value]
  end

  def destroy
    defaults "delete", resource[:domain], resource[:key]
  end

  def exists?
    value = execute([command(:defaults), "read", resource[:domain], resource[:key]], :failonfail => false)
    current_value = _normalize_value(value)
    desired_value = _normalize_value(resource[:value])
    unless current_value == desired_value
      puts "#{resource[:key]} is: '#{current_value}' and should be: '#{desired_value}'"
    end
    current_value == desired_value
  end

  def _normalize_value(value)
    value.to_s.gsub(/\n/, ' ').gsub(/ +/, '').strip
  end
end
