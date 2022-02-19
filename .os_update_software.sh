#!/bin/sh

# import utility methods
. ./.utilities.sh

# check for CLI commands
check_for_command softwareupdate
check_for_command xcode-select
# check_for_command ruby

# Check for recommended software updates
inform "Running software update on Mac OS... " true
sudo softwareupdate -i -r --ignore iTunes > /dev/null 2>&1
show "Software updated!"

# Installs OSX build tools, if not already
if [ ! -d $(xcode-select -p) ]; then
  inform "Installing OSX Build Tools..."
  xcode-select --install
  show "Complete!"
else
  show "OSX Build Tools already installed!"
fi

# TODO: If then check
