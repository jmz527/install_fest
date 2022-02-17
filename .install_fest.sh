#!/bin/sh

#
#  _           _        _ _  __           _
# (_)_ __  ___| |_ __ _| | |/ _| ___  ___| |_
# | | '_ \/ __| __/ _` | | | |_ / _ \/ __| __|
# | | | | \__ \ || (_| | | |  _|  __/\__ \ |_
# |_|_| |_|___/\__\__,_|_|_|_|  \___||___/\__|
#
# Installation, Setup and Dotfile Creation Script

#-------------------------------------------------------------------------------
# Set up basic env vars
#-------------------------------------------------------------------------------

# import utility methods
. ./.utilities.sh

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

#-------------------------------------------------------------------------------
# Set up directories
#-------------------------------------------------------------------------------

# SCRIPT_ROOT="$HOME/.code"

# mkdir -pv "$SCRIPT_ROOT"

#-------------------------------------------------------------------------------
# We begin! (utils/script_instructions.sh)
#-------------------------------------------------------------------------------

show "${BOLD}Welcome to the Installfest! ${RESET}"

# TODO: Flashy title

show "Throughout the script you will be asked to enter your password. "
show "Unless otherwise stated, this is asking for your "
show "${BOLD}computer's password. ${RESET}"
show ""
show "This script will install, update, and configure files and applications."

# capture the user's password
inform "Enter your computer's password so that " true
inform "  we can make the necessary changes. "
inform "  The password will not be visible as you type: "

sudo -p "Password:" echo "${WHITE}> Thank you! ${RESET}"

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

# # Ensure user has full control over their folder
# inform "Ensuring the current user owns their home folder." true
# sudo chown -R ${USER} ~
# show "Complete!"

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


#-------------------------------------------------------------------------------
# Capture GitHub credentials (github_capture_credentials.sh)
#-------------------------------------------------------------------------------

inform "Enter information to set up your GitHub configuration." true

read -p "Enter your Github Username: "    github_name
read -p "Enter your Github Email: "       github_email
read -s -p "Enter your Github Password: " github_password
echo ""
read -p "Enter your (real) first name: "  fname
read -p "Enter your (real) last name: "   lname

show "Thank you!"


#-------------------------------------------------------------------------------
# Create and Upload SSH key (github_add_ssh_key.sh)
#-------------------------------------------------------------------------------

# SSH keys establish a secure connection between your computer and GitHub
# This script follows these instructions
# `https://help.github.com/articles/generating-ssh-keys`

# SSH Keygen
inform "Generating an SSH key to establish a secure connection " true
inform "  your computer and GitHub. "

pause_awhile "Note: when you see the prompts:
        'Enter a file in which to save the key (...)',
        'Enter passphrase (empty for no passphrase)', and
        'Enter passphrase again'
      ${BOLD}just press Enter! Do NOT input anything!
" true

ssh-keygen -t rsa -b 4096 -C $github_email
ssh-add ~/.ssh/id_rsa

public_key=$(cat ~/.ssh/id_rsa.pub)

# TODO (PJ) test if this fails or not!
show "SSH key created..."

# Upload to GitHub
inform "Uploading SSH key to GitHub..." true

# TODO (PJ) test if this fails or not!
curl https://api.github.com/user/keys \
  -H "Accept: application/vnd.github.v3+json" \
  -u "$github_name:$github_password" \
  -d '{"title":"Home MacBook: Bethesda", "key":"'"$public_key"'"}'

echo ""
show "Key uploaded!" true


#-------------------------------------------------------------------------------
# Install Homebrew (mac/homebrew_install.sh)
#-------------------------------------------------------------------------------

grant_current_user_permissions() {
  local TARGET_DIR="$1"

  sudo mkdir -p "$TARGET_DIR"

  sudo chflags norestricted "$TARGET_DIR"

  # assumes the current user is in the group admin!
  sudo chown          $(whoami):admin "$TARGET_DIR"
  sudo chown -R       $(whoami):admin "$TARGET_DIR"
  sudo chmod u+rw     "$TARGET_DIR"
  sudo chmod -R u+rw  "$TARGET_DIR"
}

allow_group_by_acls() {
  local GROUP_NAME="$1"
  local TARGET_DIR="$2"
  local PERMISSIONS="read,write,delete,add_file,add_subdirectory"
  local INHERITANCE="file_inherit,directory_inherit"

  sudo mkdir -p "$TARGET_DIR"

  # -N and +a are special MacOSX chmod utilities that work with ACLs,
  # they are not in either GNU or BSD utilities or Man pages…
  #   -N removes all ACLs
  #   +a adds ACLs
  sudo /bin/chmod -R -N "$TARGET_DIR"
  sudo /bin/chmod -R +a "group:$GROUP_NAME:allow $PERMISSIONS,$INHERITANCE" "$TARGET_DIR"
}

inform "Installing the Homebrew package manager..." true


# vvv These fail vvv

# # Set up permissions for /usr/local to anyone in admin group!
# echo "Setting permissions of the Homebrew directory..."
# grant_current_user_permissions /usr/local
# allow_group_by_acls admin /usr/local
# show "Complete!"

# # Set up permissions for /Library/Caches/Homebrew to anyone in admin group!
# echo "Setting permissions of the Homebrew library cache..."
# grant_current_user_permissions /Library/Caches/Homebrew
# allow_group_by_acls admin /Library/Caches/Homebrew
# show "Complete!"



# Installs Homebrew, our package manager
# http://brew.sh/
$(command -v brew 2>/dev/null 1&>2)
if [[ $? != 0 ]]; then
  echo "Loading Homebrew installation script..."
  # piping echo to simulate hitting return in the brew install script
  echo | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  show "Complete!"
else
  show "Homebrew is already installed!"
fi

inform "Updating Homebrew and formulae..." true
brew update # Make sure we're using the latest Homebrew
brew upgrade # Upgrade any already-installed formulae
show "Complete!"

inform "Adding Homebrew taps..." true
# These formulae duplicate software provided by OS X
# though may provide more recent or bugfix versions, and
# extra versions (other than default) of certain packages.



# vvv These taps are deprecated vvv
# brew tap homebrew/dupes
# brew tap homebrew/versions # necessary for specific versions of libs



brew tap caskroom/cask
brew tap caskroom/fonts

# Ensures all tapped formula are symlinked into Library/Formula
# and prunes dead formula from Library/Formula.
brew tap --repair

# Remove outdated versions from the cellar
brew cleanup
show "Complete!"


#-------------------------------------------------------------------------------
# Ensure Homebrew installed correctly... (mac/homebrew_ensure_install.sh)
#-------------------------------------------------------------------------------

function i_fail_without_brew() {
  command -v brew 2>/dev/null 1&>2
  if [ $? != 0 ]; then
    BREW_FAIL="true"
  fi
}

function check_ownership_of() {
  local CURR_FILE="$1"
  local OWNER=$(ls -ld "$CURR_FILE" | awk '{print $3}')

  if [ "$OWNER" != "$USER"  ]; then
    echo "Ownership problem encountered in '${CURR_FILE}'! Should be '${USER}' but is '${OWNER}'."
    BREW_FAIL="true"
    return
  else
    echo "Ownership confirmed for '${CURR_FILE}'."
  fi
}

function check_owners_in() {
  local CURR_FILE="$1"
  if [ -f "$CURR_FILE" ]; then
    check_ownership_of $CURR_FILE
  elif [ -d "$CURR_FILE" ]; then
    check_ownership_of $CURR_FILE

    local CURR_FILES="$CURR_FILE/*"
    for CURR_F in $CURR_FILES; do
      if [ -f "$CURR_F" ]; then
        check_ownership_of $CURR_F
      fi
    done
  fi
}

inform "Ensuring that Hombrew installed correctly..." true

if [ ! -d /usr/local ]; then
  fail "Could not continue: /usr/local was not created." true
  echo ""
  exit 1;
else
  echo "Hombrew folder exists."
fi

i_fail_without_brew
if [ "$BREW_FAIL" ]; then
  fail "Could not continue: Homebrew command not available." true
  echo ""
  exit 1;
else
  echo "Homebrew 'brew' command available."
fi


# check_owners_in /usr/local  <- This fails

if [ -d /usr/local/bin ]; then
  check_owners_in /usr/local/bin
fi
if [ -d /usr/local/etc ]; then
  check_owners_in /usr/local/etc
fi
if [ -d /usr/local/var ]; then
  check_owners_in /usr/local/var
fi

if [ "$BREW_FAIL" ]; then
  fail "Could not continue; incorrect permissions in /usr/local." true
  echo ""
  exit 1
else
  echo "Permissions overview passed."
fi

show "Complete!"

#-------------------------------------------------------------------------------
# Use Homebrew to install basic libs and compilation tools (mac/homebrew_install_core_libs.sh)
#-------------------------------------------------------------------------------

# TODO: Checkout these libraries

inform "Installing core libraries via Homebrew (autoconf, automake, etc.)..." true
corepkglist=(
  # Autoconf is an extensible package of M4 macros that produce shell scripts to
  # automatically configure software source code packages.
  # autoconf

  # Automake is a tool for automatically generating Makefile.in
  automake

  # generic library support script
  # libtool

  # a YAML 1.1 parser and emitter
  # libyaml

  # neon is an HTTP and WebDAV client library
  # neon

  # A toolkit implementing SSL v2/v3 and TLS protocols with full-strength
  # cryptography world-wide.
  # openssl

  # pkg-config is a helper tool used when compiling applications and libraries.
  # pkg-config

  # a script that uses ssh to log into a remote machine
  # ssh-copy-id

  # XML C parser and toolkit
  libxml2

  # a language for transforming XML documents into other XML documents.
  # libxslt

  # a conversion library between Unicode and traditional encoding
  # libiconv

  # generates an index file of names found in source files of various programming
  # languages.
  # ctags

  # Adds history for node repl
  # readline
)

brew install ${corepkglist[@]}
show "Complete!"


#-------------------------------------------------------------------------------
# Use Homebrew to install command-line tools
#-------------------------------------------------------------------------------

inform "Installing command-line tools via Homebrew (git, node, vim, etc.)..." true
toolpkglist=(

  # Official Amazon AWS command-line interface
  awscli

  # Hashcat is a bruteforce password cracker
  # World's fastest and most advanced password recovery utility
  hashcat

  # Heroku Command Line Interface for Heroku's cloud PaaS
  heroku

  # Htop is an interactive process viewer
  # It is an improved version of the MacOS native program top
  htop

  # GO is an open source programming language to build simple/reliable/efficient software
  # go

  # IRSSI is a modular IRC client
  irssi

  # MongoDB is a high-performance, schema-free, document-oriented database
  # mongodb

  # Nmap is a port scanning utility for large networks
  nmap

  # Node is a JavaScript runtime environment built on V8 for building network applications
  node

  # Node version management
  n

  # PostgreSQL is a object-relational database system
  postgresql

  # Interpreted, interactive, object-oriented programming language
  python3

  # Command-line interface for SQLite
  sqlite

  # Display directories as trees
  tree

  # Vim is a highly configurable text editor
  vim

  # Graphical network analyzer and capture tool
  wireshark

  # Wget is an internet file retriever
  wget
)

brew install ${toolpkglist[@]}
show "Complete!"


#-------------------------------------------------------------------------------
# Use Homebrew to install command-line games & entertainment
#-------------------------------------------------------------------------------

inform "Installing games and entertainment via Homebrew (nethack, rtv, etc.)..." true
gamepkglist=(

  # Nethack is a terminal-based, single-player roguelike video game
  nethack

  # Command-line Reddit client
  rtv

  # Download YouTube videos from the command-line
  youtube-dl
)

brew install ${gamepkglist[@]}
show "Complete!"


#-------------------------------------------------------------------------------
# Use Homebrew Cask to install GUI programs
#-------------------------------------------------------------------------------
inform "Installing core GUI programs via Homebrew (google-chrome, iterm2, sublime-text, etc.)..." true
coreprglist=(

  # AppCleaner helps to thoroughly uninstall unwanted apps
  appcleaner

  # Cyberduck is an FTP client
  cyberduck

  # Firefox is an open-source web browser developed by Mozilla Foundation
  firefox

  # Desktop app for git and github
  github

  # Google Chrome is a web browser developed by Google
  google-chrome

  # Postman is an API Development Environment
  postman

  # Sublime Text is a text editor
  sublime-text

  # Visual Studio is a text editor
  visual-studio-code

  # Atom is a text editor
  atom

  # VNC Viewer is a program for remote computer control
  vnc-viewer
)

brew cask install ${coreprglist[@]}
show "Complete!"


#-------------------------------------------------------------------------------
# Use Homebrew Cask to install GUI programs
#-------------------------------------------------------------------------------
inform "Installing extra GUI programs via Homebrew (google-chrome, iterm2, sublime-text, etc.)..." true
extraprglist=(

  # Skype is a telecommunications app
  skype

  # Slack is a cloud-based collaboration and messaging app
  slack

  # Spotify is a music, podcast, and video streaming service
  spotify

  # VLC is a free and open-source, portable, cross-platform media player
  vlc

  # Evernote robust notetaking app
  evernote

  # Private Internet Access is a Virtual Private Network
  private-internet-access

  # Steam is a digital distribution platform for games
  steam

  # Transmission is a BitTorrent client
  transmission
)

brew cask install ${extraprglist[@]}
show "Complete!"



#-------------------------------------------------------------------------------
# Install Homebrew version of Git & Hub (mac/git_install_hb.sh)
#-------------------------------------------------------------------------------

inform "Installing Git & Hub via Homebrew..." true
brew install git # git is a distributed revision control system
brew install hub # additional Git commands
show "Complete!"

#-------------------------------------------------------------------------------
# Add user's Git info to ~/.gitconfig (git_configure.sh)
#-------------------------------------------------------------------------------

inform "Setting Git configurations..." true

# https://www.kernel.org/pub/software/scm/git/docs/git-config.html
git config --global user.name    "$fname $lname"
git config --global user.github  $github_name
git config --global user.email   $github_email

# set colors
git config --global color.ui always

git config --global color.branch.current   "green reverse"
git config --global color.branch.local     green
git config --global color.branch.remote    yellow

git config --global color.status.added     green
git config --global color.status.changed   yellow
git config --global color.status.untracked red

# set editor
# change to `subl -w` if you want to open merge messages in Sublime.
git config --global core.editor "nano"

# default branch to push to
git config --global push.default current

# set global gitignore
git config --global core.excludesfile ~/.gitignore_global

# Turn off rerere
git config --global rerere.enabled false

# Turn off auto rebase if the user has somehow turned it on
git config --global pull.rebase false

# add commit template
git config --global commit.template ~/.gitmessage.txt

# add some useful shortcuts
git config --global alias.s 'status'
git config --global alias.sha 'rev-parse HEAD'
git config --global alias.last 'log -1 HEAD --oneline --decorate'
git config --global alias.ll 'log --oneline --decorate'
git config --global alias.set-master 'branch --set-upstream-to=origin/master master'
git config --global alias.back 'reset --soft HEAD~1'
git config --global alias.again 'commit -c ORIG_HEAD'
git config --global alias.set-deploy = "!git config --local alias.deploy \"subtree push --prefix $1 origin gh-pages\""
git config --global alias.co 'checkout'
git config --global alias.bs 'branch -v'
git config --global alias.rs 'remote -v'
git config --global alias.ci 'commit'
show "Complete!"





#-------------------------------------------------------------------------------
# Extras
#-------------------------------------------------------------------------------

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
