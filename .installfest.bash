#!/usr/bin/env bash

#
#  _           _        _ _  __           _
# (_)_ __  ___| |_ __ _| | |/ _| ___  ___| |_
# | | '_ \/ __| __/ _` | | | |_ / _ \/ __| __|
# | | | | \__ \ || (_| | | |  _|  __/\__ \ |_
# |_|_| |_|___/\__\__,_|_|_|_|  \___||___/\__|
#
# Installation, Setup and Dotfile Creation Script


# Resources:
#
# https://github.com/thoughtbot/laptop
# https://github.com/toranb/ubuntu-development-machine
# https://github.com/divio/osx-bootstrap
# https://github.com/paulirish/dotfiles
# https://github.com/mathiasbynens/dotfiles/
# https://github.com/ndbroadbent/dotfiles

# References:
#
# http://www.sudo.ws/
# http://www.gnu.org/software/bash/manual/bashref.html
# http://www.shellcheck.net
# http://explainshell.com/



#-------------------------------------------------------------------------------
# Set up basic env vars (utils/script_env_vars.sh)
#-------------------------------------------------------------------------------

# Standard Bash Variables
# `OSTYPE` A string describing the operating system Bash is running on.
# `MACHTYPE` system type in cpu-company-system
# `SECONDS` number of seconds since the shell was started.

# FIXME (PJ) should have a better place to decide these versions:
#   Ruby (rbenv), Python (pyenv), Node (nvm)
BELOVED_RUBY_VERSION="2.2.3"
CURRENT_STABLE_RUBY_VERSION="2.2.3"

# TODO (pj) decide what the python versions should really be...
#   and maybe come up with a bigger, better place to hang this info
BELOVED_PYTHON_VERSION="anaconda-2.0.1"
CURRENT_STABLE_PYTHON_VERSION="3.4.1"

# NOT BEING USED YET, BUT SHOULD!
NODE_VERSION="stable" # using nvm's language...

if [[ "$OSTYPE" == "darwin"* ]]; then
  SYSTEM="mac"
  BASH_FILE=".bash_profile"
  MINIMUM_MAC_OS="10.7.0"
else
  SYSTEM="ubuntu"
  BASH_FILE=".bashrc"
fi

SCRIPT_ROOT="$HOME/.code"

mkdir -pv "$SCRIPT_ROOT"



#-------------------------------------------------------------------------------
# Set text formatting (utils/define_terminal_colors.sh)
#-------------------------------------------------------------------------------

# set 256 color profile where possible
if [[ $COLORTERM == gnome-* && $TERM == xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
  export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
  export TERM=xterm-256color
fi

# Reset formatting
RESET=$(      tput sgr0)

# Foreground color
BLACK=$(      tput setaf 0)
RED=$(        tput setaf 1)
GREEN=$(      tput setaf 2)
YELLOW=$(     tput setaf 3)
BLUE=$(       tput setaf 4)
MAGENTA=$(    tput setaf 5)
CYAN=$(       tput setaf 6)
WHITE=$(      tput setaf 7)

# Background color
BG_BLACK=$(   tput setab 0)
BG_RED=$(     tput setab 1)
BG_GREEN=$(   tput setab 2)
BG_YELLOW=$(  tput setab 3)
BG_BLUE=$(    tput setab 4)
BG_MAGENTA=$( tput setab 5)
BG_CYAN=$(    tput setab 6)
BG_WHITE=$(   tput setab 7)

# Style
UNDERLINE=$(  tput smul)
NOUNDERLINE=$(tput rmul)
BOLD=$(       tput bold)
ITALIC=$(     tput sitm)

#-------------------------------------------------------------------------------
# Logging (utils/log_file.sh)
#-------------------------------------------------------------------------------

# clear


# set up logfile
LOGFILE="$SCRIPT_ROOT/install.log"

exec > >(tee $LOGFILE); exec 2>&1

echo "Script compiled at: ${COMPILED_AT}"
echo "Script execution begun: $(date)"
echo ""

# utils/log_screen.sh

function show () {
  echo -e "${BG_WHITE}${BLACK}> $* ${RESET}"
}

function inform () {
  if [[ $2 ]]; then echo ""; fi
  echo -e "${BG_GREEN}${BLACK}${BOLD}>>>>  $1 ${RESET}"
}

function warn () {
  if [[ $2 ]]; then echo ""; fi
  echo -e "${BG_YELLOW}${BLACK}${BOLD}>>>>  $1 ${RESET}"
}

function fail () {
  if [[ $2 ]]; then echo ""; fi
  echo -e "${BG_RED}${WHITE}${BOLD}>>>>  $1 ${RESET}"
}

function pause_awhile () {
  if [[ $2 ]]; then echo ""; fi
  echo -e "${BG_YELLOW}${BLACK}${BOLD}>>>>  $1 ${RESET}"
  read -p "${BG_YELLOW}${BLACK}${BOLD}Press <Enter> to continue.${RESET}"
}

function pause_and_warn () {
  if [[ $2 ]]; then echo ""; fi
  echo -e "${BG_YELLOW}${BLACK}${BOLD}>>>>  $1 ${RESET}"
  echo -e "${BG_YELLOW}${BLACK}${BOLD}>>>> ${RESET}"
  read -p "${BG_YELLOW}${BLACK}${BOLD}>>>>  Continue? [Yy] ${RESET} " -n 1 -r

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    fail "Exiting..." true
    exit 1;
  fi
}

#-------------------------------------------------------------------------------
# We begin! (utils/script_instructions.sh)
#-------------------------------------------------------------------------------


show "${BOLD}Welcome to the Installfest! ${RESET}"
show ""
show "Throughout the script you will be asked to enter your password. "
show "Unless otherwise stated, this is asking for your "
show "${BOLD}computer's password. ${RESET}"
show ""
show "This script will install, update, and configure files and applications."

# utils/password_capture.sh

# capture the user's password
inform "Enter your computer's password so that " true
inform "  we can make the necessary changes. "
inform "  The password will not be visible as you type: "

sudo -p "Password:" echo "${BG_WHITE}> Thank you! ${RESET}"

# mac/os_version.sh

# Determine OS version
OS_VERSION=$(sw_vers -productVersion)


#-------------------------------------------------------------------------------
# Ensure that the user's computer set up works (mac/os_ensure_valid_setup.sh)
#-------------------------------------------------------------------------------

COMP_NAME=$(scutil --get ComputerName)
LOCL_NAME=$(scutil --get LocalHostName)
HOST_NAME=$(hostname)
USER_NAME=$(id -un)
FULL_NAME=$(finger "$USER_NAME" | awk '/Name:/ {print $4" "$5}')
USER_GRPS=$(id -Gn $USER_NAME)
OS_NUMBER=$(echo $OS_VERSION | cut -d "." -f 2)
MAC_ADDRS=$(ifconfig en0 | grep ether | sed -e 's/^[ \t|ether|\s|\n]*//')

DESCRIPTION=`cat << EOFS
      Computer Type:   Mac OS $OS_VERSION
      Short user name: $USER_NAME

      Long user name:  $FULL_NAME
      Computer name:   $COMP_NAME
      LocalHost name:  $LOCL_NAME
      Full Hostname:   $HOST_NAME
      Connection MAC:  $MAC_ADDRS
EOFS`

inform "Loading your computer's information." true
inform "Your current setup is:"
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

#-------------------------------------------------------------------------------
# Check for & install commandline tools (mac/os_install_commandline_tools.sh)
#-------------------------------------------------------------------------------

inform "Checking for XCode Command Line Tools..." true

# Check that command line tools are installed
case $OS_VERSION in
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
































