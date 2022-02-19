#!/bin/sh

# import utility methods
. ./.utilities.sh

# check for CLI commands
check_for_command softwareupdate
check_for_command xcode-select
# check_for_command ruby

if [[ "$OSTYPE" == "darwin"* ]]; then
  show "OS is darwin";
  # SYSTEM="mac"
  # BASH_FILE=".bash_profile"
  # MINIMUM_MAC_OS="10.7.0"
else
  fail "Your OS is not supported"
fi

CPU=$(sysctl -n machdep.cpu.brand_string)
# removes (R) and (TM) from the CPU name so it fits in a standard 80 window
cpu=$(echo "$CPU" | awk '$1=$1' | sed 's/([A-Z]\{1,2\})//g')

if [[ $CPU == 'Apple M1' ]]; then
  echo "Your computer is using an Apple M1 chip";
  echo $CPU;
fi

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
