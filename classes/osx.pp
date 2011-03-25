define apple_friendly_sudo($command) {
}

define check_group($group) {
  exec { "/bin/chgrp $group $name":
    unless => "/bin/sh -c '[ $(/usr/bin/stat -f %Sg $name) == $group ]'",
  }
}
define check_mode($mode) {
  exec { "/bin/chmod $mode $name":
    unless => "/bin/sh -c '[ $(/usr/bin/stat -c %OLp $name) == $mode ]'",
  }
}

class osx {
  class fix-launchd-overrides-permission {
    check_group { "/var/db/launchd.db/com.apple.launchd/overrides.plist":
      group => "admin"
    }
    check_mode { "/var/db/launchd.db/com.apple.launchd/overrides.plist":
      mode => 660
    }
  }
  class map-capslock-to-control {
    apple_preference { "map-capslock-to-control-internal-macbook-keyboard":
      domain => "~/Library/Preferences/ByHost/.GlobalPreferences.8FBA4583-7B33-5F6A-8999-5706003F3014",
      key => " com.apple.keyboard.modifiermapping.1452-544-0",
      value => "(({HIDKeyboardModifierMappingDst = 2; HIDKeyboardModifierMappingSrc = 0;}))",
      type => array
    }

    apple_preference { "map-capslock-to-control-external-wired-apple-keyboard":
      domain => "~/Library/Preferences/ByHost/.GlobalPreferences.8FBA4583-7B33-5F6A-8999-5706003F3014",
      key => " com.apple.keyboard.modifiermapping.1452-566-0",
      value => "(( { HIDKeyboardModifierMappingDst = 2; HIDKeyboardModifierMappingSrc = 0; }))",
      type => array
    }
  }

  class dock {
    /*service {"com.apple.Dock.agent":*/
    /*  enable => true,*/
    /*  ensure => running,*/
    /*  subscribe => [Apple_preference['autohide-dock-on'],*/
    /*                Apple_preference['place-dock-top'],*/
    /*                Apple_preference['place-dock-right']]*/
    /*}*/
    class autohide {
      apple_preference { "autohide-dock-on":
        domain => "org.apple.Dock",
        key => "autohide",
        value => true,
        type => "bool"
      }
    }
    class placement {
      class top-right {
        apple_preference { "place-dock-top":
          domain => "org.apple.Dock",
          key => "orientation",
          value => "top",
          type => "string"
        }
        apple_preference { "place-dock-right":
          domain => "org.apple.Dock",
          key => "pinning",
          value => "end",
          type => "bool"
        }
      }
    }
  }
}
