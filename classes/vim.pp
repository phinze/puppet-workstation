class vim {
  # TODO: figure out how to get formula from gist or maybe dropbox or local repo?
  # package { "vim": ensure => installed, provider => homebrew }

  class supporting-tools {
    package { "ack": ensure => installed, provider => homebrew }
    package { "ctags": ensure => installed, provider => homebrew }
  }
}
