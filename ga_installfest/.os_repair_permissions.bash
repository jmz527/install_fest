#!/bin/bash


# Ensure user has full control over their folder
inform "Ensuring the current user owns their home folder." true
sudo chown -R ${USER} ~
show "Complete!"

# Run repair disk permissions if prior to 10.11 (El Capitan)
if [ "$OS_NUMBER" -lt "11" ]; then
  inform "Running repair permissions..." true
  inform "  Note: this may take a VERY LONG TIME!"
  diskutil repairPermissions /
  show "Complete!"
else
  inform "Skipping repair permissions, as this is disabled as of El Capitan." true
  inform "  Search for diskutil repairPermissions and System Integrity " true
  inform "  Protection on Google to learn more. "
fi


# rbenv_remove_rvm.sh

inform "Removing RVM..." true

# Uninstall RVM, so that we can use rbenv
# http://stackoverflow.com/questions/3950260/howto-uninstall-rvm
if hash rvm 2>/dev/null || [ -d ~/.rvm ]; then
  yes | rvm implode
  rm -rf ~/.rvm
else
  show "RVM is not installed. Moving on."
fi

# mac/macports_remove.sh

inform "Removing Macports..." true

# Uninstall Macports b/c we are using Homebrew
# http://guide.macports.org/chunked/installing.macports.uninstalling.html
if hash port 2>/dev/null || [[ $(find /opt/local -iname macports 2>/dev/null) ]]; then
    macports=$(find /opt/local -iname macports)
    for f in $macports; do
      rm -rf $f
    done
  # carthago delenda est
  sudo port -fp uninstall installed
  sudo rm -rf \
    /opt/local \
    /Applications/DarwinPorts \
    /Applications/MacPorts \
    /Library/LaunchDaemons/org.macports.* \
    /Library/Receipts/DarwinPorts*.pkg \
    /Library/Receipts/MacPorts*.pkg \
    /Library/StartupItems/DarwinPortsStartup \
    /Library/Tcl/darwinports1.0 \
    /Library/Tcl/macports1.0 \
    ~/.macports
  sudo find / | grep macports | sudo xargs rm

  show "Complete!"
else
  show "Macports is not installed. Moving on."
fi
