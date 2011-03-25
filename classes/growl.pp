class growl {
  package { "growl":
    source => "http://growl.cachefly.net/Growl-1.2.1.dmg",
    provider => macapp
  }

  package { "growlnotify":
    ensure => installed,
    provider => homebrew,
    require => Package["growl"]
  }
}
