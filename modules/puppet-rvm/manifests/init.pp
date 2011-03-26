class rvm::install {
  exec { "install-rvm":
    command => "/usr/bin/curl -L http://rvm.beginrescueend.com/releases/rvm-install-head -o /tmp/rvm-installer \
                && /bin/chmod +x /tmp/rvm-installer \
                && . /tmp/rvm-installer \
                && rm /tmp/rvm-installer",
    unless => "/usr/bin/which rvm",
  }
}

class rvm {
  include rvm::install
}
