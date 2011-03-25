require 'rubygems'
require 'ruby-debug'
require 'fileutils'

unless ARGV.length == 2
  puts "usage: puppet-sudo.rb <script-name> <command>"
  exit 1
end

name = "#{ARGV[0]}"
command = "#{ARGV[1]}"
scriptfile = "/tmp/#{name}.applescript"
outputfile = "#{scriptfile}_output"
`touch #{outputfile}`
compiledscript = scriptfile.sub(/applescript$/, 'app')
compiledapplet = "#{compiledscript}/Contents/MacOS/applet"
script = <<-SCRIPTEND
  set output to (open for access (POSIX file "#{outputfile}") with write permission)
  write (do shell script "#{command}" with administrator privileges without altering line endings) to output
  close access output
SCRIPTEND

File.open(scriptfile, 'w') do |f|
  f.puts script
end

compiled_result = `/usr/bin/osacompile -o #{compiledscript} #{scriptfile}`

result = `#{compiledapplet}`

File.open(outputfile, 'r') do |f|
  puts f.read
end

File.delete(outputfile)
File.delete(scriptfile)
FileUtils.rm_rf(compiledscript)

exit 0
