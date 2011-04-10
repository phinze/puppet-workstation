# XXX: this doesn't work yet
Puppet::Type.newtype(:apple_exec, :parent => Puppet::Type.type(:exec)) do
  @doc = "Just like exec but with the ability to elevate privileges gracefully"

  newparam(:as_admin) do
    desc "Run command with administrator privileges"
    validate do |value|
      unless [true,false].include?(value)
        raise ArgumentError , "%s is not a valid value" % value
      end
    end
  end

  [:command, :unless].each do |param_name|
    param = self.superclass.attrclass(param_name)

    unless param
        raise Puppet::DevError, "Class %s has no param %s" % [self.superclass, param_name]
    end
    @parameters << param
    @parameters.each { |p| @paramhash[param_name] = p }

    if param.isnamevar?
      @namevar = param.name
    end
  end


  # Override superclass to check whether to use alternative privilege escalating exec mechanism
  def run(command, check = false)
    debugger
    unless @resource[:as_admin]
      super
    else
      scriptfile = "/tmp/#{@resource[:name]}.applescript"
      outputfile = "#{scriptfile}_output"
      `touch #{outputfile}`
      compiledscript = scriptfile.sub(/applescript$/, 'app')
      compiledapplet = "#{compiledscript}/Contents/MacOS/applet"
      script = <<-SCRIPTEND
        set output to (open for access (POSIX file "#{outputfile}") with write permission)
        write (do shell script "#{@resource[:command]}" with administrator privileges without altering line endings) to output
        close access output
      SCRIPTEND

      File.open(scriptfile, 'w') do |f|
        f.puts script
      end

      compiled_result = `/usr/bin/osacompile -o #{compiledscript} #{scriptfile} 2>/dev/null`

      result = `#{compiledapplet}`

      File.open(outputfile, 'r') do |f|
        puts f.read
      end

      File.delete(outputfile)
      File.delete(scriptfile)
      FileUtils.rm_rf(compiledscript)
    end
  end
end
