import "classes/*.pp"
import "puppet-rvm"

class workstation {
  package { "googlechrome":
    source => "https://dl-ssl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg",
    provider => macapp
  }

  package { "dropbox":
    source => "http://cdn.dropbox.com/Dropbox%201.0.20.dmg",
    provider => macapp
  }

  package { "pgpdesktop":
    source => "dropbox://apps/PGPDesktop10.1.1.dmg",
    provider => macapp
  }

  package { "hexfiend":
    source => "http://ridiculousfish.com/hexfiend/files/HexFiend.dmg",
    provider => macapp
  }

  package { "vlc":
    source => "http://sourceforge.net/projects/vlc/files/1.1.7/macosx/vlc-1.1.7.dmg/download",
    provider => macapp
  }

  package { "caffeine":
    source => "http://download.lightheadsw.com/download.php?software=caffeine",
    provider => macapp
  }

  include rvm
  rvm_ruby { "ruby-1.8.7-p249":
    default_ruby => true,
    ensure => present
  }

  include adium
  include growl
  include osx
#  include osx::fix-launchd-overrides-permission
  include osx::dock
  include osx::dock::autohide::on
  include osx::dock::placement::right
  include osx::map-capslock-to-control
  include quicksilver
  include vim
  include vim::supporting-tools
}

node default {
  include workstation
}
