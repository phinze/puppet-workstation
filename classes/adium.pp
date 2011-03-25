class adium {
  package { "adium":
    source => "http://download.adium.im/Adium_1.4.1.dmg",
    provider => macapp
  }
}
