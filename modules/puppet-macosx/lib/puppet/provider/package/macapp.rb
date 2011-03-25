require 'puppet/provider/package'
require 'facter/util/plist'
require 'open-uri'
require 'ruby-debug'

Puppet::Type.type(:package).provide(:macapp, :parent => Puppet::Provider::Package) do
  desc <<-END
Package management based on Apple's Installer.app and DiskUtility.app.  This
package works by checking the contents of a DMG image for Apple pkg, mpkg, or app
files. Any number of pkg, mpkg, or app files may exist in the root directory of
the DMG file system. Sub directories are not checked for packages.  See `the wiki
docs
<http://projects.puppetlabs.com/projects/puppet/wiki/Package_Management_With_Dmg_Patterns>`
for more detail."
END


  confine :operatingsystem => :darwin

  commands :curl => "/usr/bin/curl"
  commands :ditto => "/usr/bin/ditto"
  commands :hdiutil => "/usr/bin/hdiutil"
  commands :installer => "/usr/sbin/installer"
  commands :osascript => "/usr/bin/osascript"
  commands :sudo => "/usr/bin/sudo"
  commands :tar => "/usr/bin/tar"
  commands :touch => "/usr/bin/touch"
  commands :unzip => "/usr/bin/unzip"
  commands :usrbinfile => "/usr/bin/file" # naming a command :file causes "stack level too deep" error
  commands :mkdir => "/bin/mkdir"
  commands :rm => "/bin/rm"

  RECEIPTS_PATH="/Library/Receipts/puppet"
  RECEIPT_PREFIX="macapp_installed_"

  VALID_SOURCE_SUFFIXES = ['dmg', 'pkg', 'app']

  def self.instance_by_name
    Dir.entries(RECEIPTS_PATH).grep(/^#{RECEIPT_PREFIX}/).map do |f|
      name = f.sub(/^#{RECEIPT_PREFIX}/, '')
      yield name if block_given?
      name
    end
  end

  def self.instances
    instance_by_name.map { |name| new(:name => name, :provider => :macapp, :ensure => :installed) }
  end

  def initialize(*args)
    unless FileTest.directory?(RECEIPTS_PATH)
      FileUtils.mkdir(RECEIPTS_PATH, :mode => 0770)
    end
    super(*args)
  end

  def install
    _validate_resource
    _with_extracted_mountpoints(_resolve_path(@resource[:source])) do |mountpoint|
      Dir.entries(mountpoint).grep(/(#{VALID_SOURCE_SUFFIXES.join('|')})$/) do |path|
        suffix = path.split('.').last
        send("install_#{suffix}".to_sym, File.join(mountpoint, path))
      end
    end
    _save_receipt
  end

  def install_pkg(pkgpath)
    installer_command = [command(:installer), "-pkg", pkgpath, "-target", "/"]
    foobar = execute(installer_command, :failonfail => false)
    debugger
    script = %(do shell script "#{installer_command.join(' ')}" with administrator privileges)
    #execute([command(:osascript), '-e', script])
  end
  alias :install_mpkg :install_pkg

  def install_app(apppath)
    appname = File.basename(apppath);
    ditto "--rsrc", apppath, "/Applications/#{appname}"
  end

  def query
    {:name => @resource[:name], :ensure => :present} if FileTest.exists?(_receipt_file)
  end

  def _receipt_file
    "#{RECEIPTS_PATH}/#{RECEIPT_PREFIX}#{@resource[:name]}"
  end

  def _resolve_path(source)
    uri = URI.parse(source)
    case uri.scheme
    when "dropbox"
      File.expand_path("~/Dropbox/#{File.join(uri.host,uri.path)}")
    when "http", "https"
      cached_source = "/tmp/#{source.gsub(/[^a-zA-Z0-9]/, '')}"
      touch cached_source
      execute([command(:curl), "-s", "-o", cached_source, "-L", "-C", "-", "-k", "--url", source], :stdinfile => cached_source)
      cached_source
    else
      source
    end
  end

  def _save_receipt
    File.open(_receipt_file, "w") do |t|
      t.puts "name: '#{@resource[:name]}"
      t.puts "source: '#{@resource[:source]}"
    end
  end

  def _validate_resource
    raise Puppet::Error.new("Mac Apps must specify a package source.") unless @resource[:source]
    raise Puppet::Error.new("Mac Apps must specify a package name.") unless @resource[:name]
  end

  def _with_extracted_mountpoints(path)
    if _dmg?(path)
      File.open(path) do |dmg|
        xml_str = hdiutil "mount", "-plist", "-nobrowse", "-readonly", "-noidme", "-mountrandom", "/tmp", dmg.path
        hdiutil_info = Plist::parse_xml(xml_str)
        raise Puppet::Error.new("No disk entities returned by mount at #{dmg.path}") unless hdiutil_info.has_key?("system-entities")
        mounts = hdiutil_info["system-entities"].collect { |entity|
          entity["mount-point"]
        }.compact
        begin
          mounts.each do |mountpoint|
            yield mountpoint
          end
        ensure
          mounts.each do |mountpoint|
            hdiutil "eject", mountpoint
          end
        end
      end
    elsif _tgz?(path)
      destdir = "/tmp/puppet_#{@resource[:name]}_extracted"
      mkdir '-p', destdir
      tar 'zxf', path, '-C', destdir
      yield destdir
      rm '-rf', destdir
    elsif _zip?(path)
      destdir = "/tmp/puppet_#{@resource[:name]}_extracted"
      mkdir '-p', destdir
      unzip '-d', destdir, path
      yield destdir
      rm '-rf', destdir
    else
      raise "uh oh, could not identify type of #{path}"
    end
  end

  def _dmg?(path)
    output = execute([command(:hdiutil), 'imageinfo', path], :failonfail => false)
    output != ''
  end

  def _tgz?(path)
    output = execute([command(:usrbinfile), '-Izb', path], :failonfail => false)
    output.chomp == 'application/x-tar; charset=binary compressed-encoding=application/x-gzip; charset=binary; charset=binary'
  end

  def _zip?(path)
    output = execute([command(:usrbinfile), '-Izb', path], :failonfail => false)
    output.chomp == 'application/x-empty compressed-encoding=application/zip; charset=binary; charset=binary'
  end
end
