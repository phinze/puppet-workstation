# define check_group($group) {
#   apple_exec { "check-group-$group":
#     command => "/bin/chgrp $group $name",
#     as_admin => true,
#     unless => "/bin/sh -c '[ $(/usr/bin/stat -f %Sg $name) == $group ]'"
#   }
# }
# define check_mode($mode) {
#   apple_exec { "/bin/chmod $mode $name":
#     unless => "/bin/sh -c '[ $(/usr/bin/stat -c %OLp $name) == $mode ]'",
#   }
# }

class osx {
#   class fix-launchd-overrides-permission {
#     check_group { "/var/db/launchd.db/com.apple.launchd/overrides.plist":
#       group => "admin"
#     }
#     check_mode { "/var/db/launchd.db/com.apple.launchd/overrides.plist":
#       mode => 660
#     }
#   }
  class map-capslock-to-control {
    apple_preference { "map-capslock-to-control-internal-macbook-keyboard":
      domain => "~/Library/Preferences/ByHost/.GlobalPreferences.8FBA4583-7B33-5F6A-8999-5706003F3014",
      key => " com.apple.keyboard.modifiermapping.1452-544-0",
      value => "((({HIDKeyboardModifierMappingDst = 2; HIDKeyboardModifierMappingSrc = 0;})))",
      type => array,
      ensure => present
    }

    apple_preference { "map-capslock-to-control-external-wired-apple-keyboard":
      domain => "~/Library/Preferences/ByHost/.GlobalPreferences.8FBA4583-7B33-5F6A-8999-5706003F3014",
      key => " com.apple.keyboard.modifiermapping.1452-566-0",
      value => "((({ HIDKeyboardModifierMappingDst = 2; HIDKeyboardModifierMappingSrc = 0; })))",
      type => array,
      ensure => present
    }
  }

  class dock {
#     service {"com.apple.Dock.agent":
#       enable => true,
#       ensure => running,
#       subscribe => [
#                     Apple_preference['autohide-dock-on'],
#                     Apple_preference['place-dock-right']],
#       require => Class["fix-launchd-overrides-permission"]
#     }
    exec { "restart-dock":
      command => "/usr/bin/killall Dock",
      refreshonly => true
    }
    class autohide {
      class on {
        apple_preference { "autohide-dock-on":
          domain => "com.apple.Dock",
          key => "autohide",
          value => true,
          type => "bool",
          ensure => present,
          notify => Exec["restart-dock"]
        }
      }
      class off {
        apple_preference { "autohide-dock-off":
          domain => "com.apple.Dock",
          key => "autohide",
          value => false,
          type => "bool",
          ensure => present,
          notify => Exec["restart-dock"]
        }
      }
    }
    class placement {
      class right {
        apple_preference { "place-dock-right":
          domain => "com.apple.Dock",
          key => "orientation",
          value => "right",
          type => "string",
          ensure => present,
          notify => Exec["restart-dock"]
        }
      }
    }
  }
}
