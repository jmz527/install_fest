
#-------------------------------------------------------------------------------
# Ensure that the user's computer set up works (mac/os_ensure_valid_setup.sh)
#-------------------------------------------------------------------------------

# Determine OS version
OS_VERSION=$(sw_vers -productVersion)

COMP_NAME=$(scutil --get ComputerName)
LOCL_NAME=$(scutil --get LocalHostName)
HOST_NAME=$(hostname)
USER_NAME=$(id -un)
FULL_NAME=$(finger "$USER_NAME" | awk '/Name:/ {print $4" "$5}')
USER_GRPS=$(id -Gn $USER_NAME)
OS_NUMBER=$(echo $OS_VERSION | cut -d "." -f 2)
MAC_ADDRS=$(ifconfig en0 | grep ether | sed -e 's/^[ \t|ether|\s|\n]*//')

DESCRIPTION=`cat << EOFS
      Short user name: $USER_NAME
      Long user name:  $FULL_NAME
      IP address:  $MAC_ADDRS
EOFS`

inform "Loading your computer's information." true
inform "Your current setup is:"
./.archey.bash -o
printf "$DESCRIPTION\n"
inform "Checking the validity of this set up."
inform "If it is not valid, it will fail or warn you."
echo "..."

# Check if current user is admin.

if echo "$USER_GRPS" | grep -q -w admin; then
  echo "" > /dev/null
else
  fail "The current user does not have administrator privileges. You must " true
  fail "  run this program from an admin user. Ask an instructor for help."
  fail "Exiting..." true
  exit 1
fi

# Check if OS version is valid.

if [ "$OS_NUMBER" -lt "6" ]; then
  fail "You need to have Mac OS X 10.6 (Snow Leopard) or higher installed" true
  fail "  in order to take WDI. Please contact an instructor or producer."
  fail "Exiting..." true
  exit 1
fi

if [ "$OS_NUMBER" -eq "6" ]; then
  warn "Warning!" true
  warn "While you can take WDI with  Mac OS X 10.6 (Snow Leopard), it is "
  warn "  not supported by this script. You can continue to run the      "
  warn "  script, but any problems need to be taken care of by your      "
  warn "  instructional team. It is recommended that you upgrade your    "
  pause_and_warn "  computer.                                                      "
fi

# Check if username is valid.

if [[ "$USER_NAME" =~ " " ]]; then
  fail "Your username '${USER_NAME}' has a space. This complictes using " true
  fail "  command line tools, and can even break some programs. Change  "
  fail "  your username before continuing.                              "
  fail "Exiting..." true
  exit 1
fi

LOWERCASE=$(echo "$USER_NAME" | tr '[A-Z]' '[a-z]')
if [ "$USER_NAME" != "$LOWERCASE" ]; then
  warn "Warning!" true
  warn "Your username '${USER_NAME}' has 'mixed-case'; it should be entirely in "
  warn "  lowercase. This could lead to some issues where certain tools "
  warn "  that are case-sensitive, and others that are not, don't work  "
  warn "  well together. It is suggested that you change your username. "
  pause_and_warn "  PS: this also goes for your GitHub username!                  "
fi

show "Setup is valid!"


#-------------------------------------------------------------------------------
# Update software on Mac (mac/os_update_software.sh)
#-------------------------------------------------------------------------------

# Check for recommended software updates
inform "Running software update on Mac OS... " true
sudo softwareupdate -i -r --ignore iTunes > /dev/null 2>&1
show "Software updated!"

# TODO: If then check


#-------------------------------------------------------------------------------
# Check for & install commandline tools (mac/os_install_commandline_tools.sh)
#-------------------------------------------------------------------------------

inform "Checking for XCode Command Line Tools..." true

# Check that command line tools are installed
case $OS_VERSION in
  *10.13*) cmdline_version="CLTools_Executables" ;; # High Sierra
  *10.12*) cmdline_version="CLTools_Executables" ;; # Sierra
  *10.11*) cmdline_version="CLTools_Executables" ;; # El Capitan
  *10.10*) cmdline_version="CLTools_Executables" ;; # Yosemite
  *10.9*)  cmdline_version="CLTools_Executables" ;; # Mavericks
  *10.8*)  cmdline_version="DeveloperToolsCLI"   ;; # Mountain Lion
  *10.7*)  cmdline_version="DeveloperToolsCLI"   ;; # Lion
  *10.6*)  cmdline_version="DeveloperToolsCLILeo"
           fail "Outdated OS. Considering upgrading before continuing." true;; # Snow Leopard
           # Force the user to upgrade if they're below 10.6
  *) fail "Sorry! You'll have to upgrade your OS to $MINIMUM_MAC_OS or above." true; exit 1;;
esac

# Check for Command Line Tools based on OS versions
if [ ! -z $(pkgutil --pkgs=com.apple.pkg.$cmdline_version) ]; then
  show "Command Line Tools are installed!"
elif [[ $OS_VERSION == *10.6** ]]; then
  fail "Command Line Tools are not installed!" true
  fail "  Downloading and installing the GCC compiler."
  fail "  When you're done rerun the Installfest script..."
  curl -OLk https://github.com/downloads/kennethreitz/osx-gcc-installer/GCC-10.6.pkg
  open GCC-10.6.pkg
  exit 1
elif [[ $OS_VERSION == *10.7* ]] || [[ $OS_VERSION == *10.8* ]]; then
  fail "Command Line Tools are not installed!" true
  fail "Register for a Developer Account"
  fail "  Download the Command Lion Tools from:"
  fail "    https://developer.apple.com/downloads/index.action"
  fail "  and then rerun the Installfest script..."
  exit 1
else
  fail "Command Line Tools are not installed!" true
  fail "  Running 'xcode-select --install' Please click continue!"
  fail "  After installing please rerun the Installfest script..."
  xcode-select --install
  exit 1
fi


#-------------------------------------------------------------------------------
# Repair disk permissions (mac/os_repair_permissions.sh)
#-------------------------------------------------------------------------------

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

