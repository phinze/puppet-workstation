# Puppet a developer workstation from scratch.

## This is a work in progress!

This is super-alpha; I'm currently running this on my machine to drive out
changes and bugfixes.  The list of to-dos is still incredibly long, and I would
not recommend using this until it's a little further along.

At this point I'm developing this in a single repository, but I plan on
extracting the osx-specific puppet extensions into their own modules once I'm
happy with them.

## Holy Grail

 1. Install OSX Snow Leopard
 1. `gem install puppet`
 1. `curl -O http://someday.github.com/phinze/puppet-workstation.tgz && tar zxf puppet-workstation.tgz`
 1. `cd puppet-workstation; ~/.gem/ruby/1.8/puppet apply puppet.pp`
 1. **Enjoy fully installed and configured developer workstation.**

### Secondary Goals

 * acquire root privs only when necessary, and make it obvious why they are necessary when password is requested
 * properly connect puppet `require`s -- only one invocation of `puppet apply` should be necessary
 * don't give puppet the ability change anything that it does not also have the ability to change back

## Current features

### <tt>macapp</tt> package provider

 * Given a URL, will download and install a mac application
 * Started as a combination of the existing `pkgdmg` and `appdmg` providers
 * Now will recognize and install `app` and `pkg` files inside of `dmg`, `zip`, and, `tgz` containers
 * Has ability to source applications from Dropbox for non-publically-available apps with `dropbox://`
 * **TODO**: support elevating privileges when installing `pkg`s that require it, so puppet itself does not need

### <tt>apple_preference</tt> resource type

 * Low-level wrapper allowing the maintenance of speicifc keys in Apple Preference `plist` files
 * Currently successfully used to:
   - script the mapping of capslock to control
   - provide some basic settings around the dock
 * Plan is to extend this with children to a cleaner interface for Dock settings, Adium accounts, and other fun `plist`-backed settings

### <tt>homebrew</tt> package provider

 * Borrowing this from [jedi4ever](https://github.com/jedi4ever/puppet-homebrew); so far I haven't had to even look at the code.  Thanks jedi4ever!
 * **TODO**: have puppet manage the install homebrew itself

## A small selection of future features

 * Install and manage rvm rubies and gemsets
 * Clone git repositories into place
 * Clone and symlink in dotfiles from a repository
 * Lots of app-specfic configuration abilities: Terminal, Adium, Chrome, other System Preferences
 * Pies; skies; etc...
