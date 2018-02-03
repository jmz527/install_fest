#!/usr/bin/env bash

COMPILED_AT='Mon Sep 26 14:44:46 PDT 2016'
#
#  _           _        _ _  __           _
# (_)_ __  ___| |_ __ _| | |/ _| ___  ___| |_
# | | '_ \/ __| __/ _` | | | |_ / _ \/ __| __|
# | | | | \__ \ || (_| | | |  _|  __/\__ \ |_
# |_|_| |_|___/\__\__,_|_|_|_|  \___||___/\__|
#
# Installation, Setup and Dotfile Creation Script
# for Students of General Assemb.ly's WDI Program

# Authors: Phillip Lamplugh, GA Instructor (2014),
#          PJ Hughes, GA Instructor (2014 & 2015)

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

SCRIPT_ROOT="$HOME/.wdi"

# TODO (PJ) this needs to be more robust, BY FAR!
SCRIPT_REPO="https://github.com/GA-WDI/installfest_script.git"
SCRIPT_REPO_BRANCH="master"

# the downloaded repo
SCRIPT_DIR="$SCRIPT_ROOT/installfest"
SCRIPT_SETTINGS="$SCRIPT_DIR/settings"

SCRIPT_DOTFILES=$SCRIPT_SETTINGS/dotfiles/*
SCRIPT_FONTS=$SCRIPT_SETTINGS/fonts/*
SCRIPT_SUBL_SETTINGS=$SCRIPT_SETTINGS/sublime_settings/*
SCRIPT_SUBL_PACKAGES=$SCRIPT_SETTINGS/sublime_packages/*
SCRIPT_THEMES=$SCRIPT_SETTINGS/terminal/*

# the working folder
STUDENT_FOLDER="$HOME/code/wdi"

# Deprecated as part of the utils/report_log.sh system...
# TODO (PJ) update how reporting is done?
# OWNER="ga-students"
# REPO="wdi_melville_instructors"

mkdir -p "$SCRIPT_ROOT"

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

clear

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
show "This script will install, update, and configure files and "
show "applications that you will use in class."

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
  -H "User-Agent: WDIInstallFest" \
  -H "Accept: application/vnd.github.v3+json" \
  -u "$github_name:$github_password" \
  -d '{"title":"WDI Installfest", "key":"'"$public_key"'"}'

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

# Set up permissions for /usr/local to anyone in admin group!
echo "Setting permissions of the Homebrew directory..."
grant_current_user_permissions /usr/local
allow_group_by_acls admin /usr/local
show "Complete!"

# Set up permissions for /Library/Caches/Homebrew to anyone in admin group!
echo "Setting permissions of the Homebrew library cache..."
grant_current_user_permissions /Library/Caches/Homebrew
allow_group_by_acls admin /Library/Caches/Homebrew
show "Complete!"

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
brew tap homebrew/dupes
brew tap homebrew/versions # necessary for specific versions of libs

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

check_owners_in /usr/local
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
# Use Homebrew to install basic libs and compilation tools
# (mac/homebrew_install_core_libs.sh)
#-------------------------------------------------------------------------------

inform "Installing core libraries via Homebrew (autoconf, automake, etc.)..." true
packagelist=(
  # Autoconf is an extensible package of M4 macros that produce shell scripts to
  # automatically configure software source code packages.
  autoconf

  # Automake is a tool for automatically generating Makefile.in
  automake

  # generic library support script
  libtool

  # a YAML 1.1 parser and emitter
  libyaml

  # neon is an HTTP and WebDAV client library
  # neon

  # A toolkit implementing SSL v2/v3 and TLS protocols with full-strength
  # cryptography world-wide.
  openssl

  # pkg-config is a helper tool used when compiling applications and libraries.
  pkg-config

  # a script that uses ssh to log into a remote machine
  ssh-copy-id

  # XML C parser and toolkit
  libxml2

  # a language for transforming XML documents into other XML documents.
  libxslt

  # a conversion library between Unicode and traditional encoding
  libiconv

  # generates an index file of names found in source files of various programming
  # languages.
  ctags

  # Adds history for node repl
  readline
)

brew install ${packagelist[@]}
show "Complete!"

#-------------------------------------------------------------------------------
# Install Homebrew version of Git & Hub (mac/git_install_hb.sh)
#-------------------------------------------------------------------------------

inform "Installing Git & Hub via Homebrew..." true
brew install git
brew install hub # additional Git commands
show "Complete!"

#-------------------------------------------------------------------------------
# Install Git Completion (git_completion.sh)
#-------------------------------------------------------------------------------

inform "Installing a bash script to support Git CLI tab-completion..." true

GIT_COMPLETION_URL="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
GIT_COMPLETION_FILE="$HOME/.git-completion.bash"

curl -o "$GIT_COMPLETION_FILE" "$GIT_COMPLETION_URL"

if [[ -e "$GIT_COMPLETION_FILE" ]]; then
  show "File '$GIT_COMPLETION_FILE' created!"
else
  fail "${GIT_COMPLETION_FILE} not created... " true
  pause_awhile "Ask an instructor for help if necessary. "
fi

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
# Install rbenv (rbenv_install.sh)
#-------------------------------------------------------------------------------

inform "Installing rbenv, our Ruby version manager..." true

RBENV_DIR="$HOME/.rbenv"

if [[ -e "$RBENV_DIR" ]]; then
  show "Already installed! Moving on..."
else
  # Not using brew install (on Mac) because it is problematic...
  git clone https://github.com/sstephenson/rbenv.git "$RBENV_DIR"
fi

# enable shims and autocompletion for the rest of this script...
# this also needs to run in the bash_profile
export PATH="${RBENV_DIR}/bin:$PATH"
eval "$(rbenv init -)"

inform "Installing rbenv plugins..." true

RBENV_REHASH="${RBENV_DIR}/plugins/rbenv-gem-rehash"
RBENV_DEFAULT="${RBENV_DIR}/plugins/rbenv-default-gems"
RBENV_BUILD="${RBENV_DIR}/plugins/ruby-build"

if [[ -e "$RBENV_REHASH" ]]; then
  show "Rehash plugin already installed! Moving on..."
else
  # Automatically install gems every time you install a new version of Ruby
  git clone https://github.com/sstephenson/rbenv-gem-rehash.git "$RBENV_REHASH"
fi

if [[ -e "$RBENV_DEFAULT" ]]; then
  show "Default gems plugin installed! Moving on..."
else
  # Automatically runs rbenv rehash every time you install or uninstall a gem
  git clone https://github.com/sstephenson/rbenv-default-gems.git "$RBENV_DEFAULT"
fi

if [[ -e "$RBENV_BUILD" ]]; then
  show "Ruby build plugin already installed! Moving on..."
else
  # Provides an `rbenv install` command
  # ruby-build is a dependency of rbenv-default-gems, so it gets installed
  # TODO (PJ) remove then?
  git clone https://github.com/sstephenson/ruby-build.git "$RBENV_BUILD"
fi

show "Complete!"

#-------------------------------------------------------------------------------
# Set default gems to install by rbenv (rbenv_set_default_gems.sh)
#-------------------------------------------------------------------------------

inform "Setting default gems to install with Ruby versions..." true

# Make sure we skip documentation installation during install...
# There is a more full .gemrc that will be installed with dotfiles later.
echo "gem: --no-ri --no-rdoc" > ~/.gemrc

touch "${RBENV_DIR}/default-gems"

# Our gems to install
GEMLIST=(
  bundler         # Maintains a consistent environment for ruby applications.
  # capybara        # Acceptance test framework for web applications
  # guard           # handle events on file system modifications
  # jasmine         # JavaScript testing
  pry             # alternative to the standard IRB shell
  # pry-coolline    # live syntax highlighting for the Pry REPL
  # rails           # full stack, Web application framework
  # rspec           # testing tool for Ruby
  # sinatra         # a DSL for quickly creating web applications in Ruby
  # sinatra-contrib # common Sinatra extensions
  github_api      # Ruby interface to github API v3
  # hipchat         # HipChat HTTP API Wrapper
  awesome_print   # pretty print your Ruby objects with style
  rainbow         # colorizing printed text on ANSI terminals
)

for gem in ${GEMLIST[@]}; do
  echo "${gem}" >> "${RBENV_DIR}/default-gems"
done

show "Complete!"

#-------------------------------------------------------------------------------
# Install Ruby (rbenv_install_version.sh)
#-------------------------------------------------------------------------------

inform "Installing correct Ruby version and optimizing for your system..." true
inform "  Note: this may take a VERY LONG TIME!"

ruby_check=$(rbenv versions | grep $BELOVED_RUBY_VERSION)

if [[ "$ruby_check" == *$BELOVED_RUBY_VERSION* ]]; then
  show "$BELOVED_RUBY_VERSION is installed! Moving on..."
else
  rbenv install $BELOVED_RUBY_VERSION
fi

# rbenv_set_version.sh

rbenv global $BELOVED_RUBY_VERSION
rbenv rehash

# mac/nvm_setup.sh

inform "Preparing nvm installation by cleaning up current state of Node." true

# Remove any Node brew installation and any global npm modules from it
brew remove --force node
sudo rm -r /usr/local/lib/node_modules >/dev/null 2>&1

show "Done!"

#-------------------------------------------------------------------------------
# Install NVM (nvm_install.sh)
#-------------------------------------------------------------------------------

inform "Installing nvm, our Node version manager..." true

NVM_DIR="$HOME/.nvm"

if [[ -e "$NVM_DIR" ]]; then
  show "Already installed. Moving on..."
else
  # install Node Version Manager
  git clone https://github.com/creationix/nvm.git "$NVM_DIR" && cd "$NVM_DIR" && git checkout `git describe --abbrev=0 --tags`
  show "Complete!"
fi

#-------------------------------------------------------------------------------
# Install Node (nvm_install_version.sh)
#-------------------------------------------------------------------------------

inform "Installing correct Node version and updated NPM..." true

# load nvm command in the script
# will do this and more in the bash_profile for the users
source ~/.nvm/nvm.sh

# Install and use version using NVM
nvm install "$NODE_VERSION"

# Ensure we have the most recent version of npm
npm install npm -g

show "Complete!"

#-------------------------------------------------------------------------------
# Use Brew to GNU's version of the core Unix utilites: ls, cat, find, etc.
# (mac/homebrew_install_core_utils.sh)
#-------------------------------------------------------------------------------

inform "Installing GNU core utils via Homebrew (gls, gcat, gfind, etc.)..." true

packagelist=(
  # The essential GNU core utilities.
  # Linked to /usr/local/bin.
  # Linked in /usr/local/opt/coreutils/libexec/gnubin without the "g"-prefix
  #   in case you want to override the OS X defaults. The default bash_profile
  #   included in /settings should have clear directions on how to do this!
  coreutils

  # Homebrew coreutils message about PATH and loading the GNU coreutils by
  # default.
  # --------------------------------------------------------------------
  # ==> Caveats
  # All commands have been installed with the prefix 'g'.
  #
  # If you really need to use these commands with their normal names, you
  # can add a "gnubin" directory to your PATH from your bashrc like:
  #
  #     PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
  #
  # Additionally, you can access their man pages with normal names if you add
  # the "gnuman" directory to your MANPATH from your bashrc as well:
  #
  #     MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
  # --------------------------------------------------------------------

  # More: gfind, glocate, gupdatedb, gxargs
  # Linked to /usr/local/bin.
  findutils

  # Further GNU utilities can be added with the following packages. For
  # more, see
  # https://www.topbug.net/blog/2013/04/14/install-and-use-gnu-command-line-tools-in-mac-os-x/
  #
  # binutils
  # coreutils (--with-default-names)
  # diffutils
  # ed (--with-default-names)
  # findutils (--with-default-names)
  # gawk
  # gnu-getopt (--with-default-names)
  # gnu-indent (--with-default-names)
  # gnu-sed (--with-default-names)
  # gnu-tar (--with-default-names)
  # gnu-which (--with-default-names)
  # gnutls
  # grep (--with-default-names)
  # gzip
  # screen
  # watch
  # wdiff (--with-gettext)
  # wget
)

brew install ${packagelist[@]}

show "Complete!"

#-------------------------------------------------------------------------------
# Use Brew to install important CLI tools (mac/homebrew_install_core_tools.sh)
#-------------------------------------------------------------------------------

inform "Installing CLI apps via Homebrew (qt, sqlite, etc.)..." true

# Useful packages
packagelist=(
  # ASCII ART!!!!
  figlet

  # visualization tool for ERDs
  graphviz

  # Image resizing
  imagemagick

  # PhantomJS is a headless WebKit scriptable with a JavaScript API
  phantomjs

  # WebKit implementation of qt for Capybara testing
  qt

  # Qt for Mac OS X
  qt4

  # Advanced in-memory key-value store that persists on disk
  redis

  # A self-contained, serverless, zero-configuration, transactional SQL
  # database engine
  sqlite

  # Update Subversion
  # svn

  # Directory visualizer
  tree

  # Git visualization
  tig
)

brew install ${packagelist[@]}

# Note (PJ) Emacs and Vim?
# brew install emacs
# brew install vim --override-system-vi
# brew install macvim --override-system-vim --custom-system-icons

# Others...
# brew install bash
# Mac OS ships with bash 3.2
# http://www.admon.org/applications/new-features-in-bash-4-0/
# brew install gdb
# gdb requires further actions to make it work. See `brew info gdb`.
# brew install gpatch
# brew install m4
# brew install make
# brew install nano
# brew install file-formula
# brew install git
# brew install less
# brew install openssh
# brew install rsync
# brew install unzip
# brew install zsh

show "Complete!"

#-------------------------------------------------------------------------------
# Use Brew Cask to install application images (mac/homebrew_install_apps.sh)
#-------------------------------------------------------------------------------

# PJ: REMOVED THE BELOW, now that cask has been added to Homebrew
# See https://github.com/caskroom/homebrew-cask/pull/15381

# inform "Installing Homebrew Cask, to handle Mac binaries (apps)..." true
# a CLI workflow for the administration of Mac applications
# distributed as binaries
# brew tap phinze/homebrew-cask
# brew install brew-cask

# PJ: Removed the below, now that it seems Sublime Text 3 is the default
# package for Homebrew, and sublime-text3 no longer exists…
# https://github.com/caskroom/homebrew-cask/pull/22236

# load a tap of different versions of apps (for Sublime Text 3)
# inform "Tapping Homebrew Cask's versions, for ST3..." true
# brew tap caskroom/versions
# show "Complete!"

inform "Using Homebrew Cask to install GUI apps..." true

# PJ: removed b/c too many students were afraid of having double
# installs. Added note to README to this effect.

# Our browser(s)
# ----------------------------------------------------------------------
# brew cask install google-chrome
# brew cask install google-chrome-canary

# brew cask install firefox
# brew cask install firefox-nightly
# ----------------------------------------------------------------------

# Out text editor
# ----------------------------------------------------------------------
# The Text Editor, Sublime Text 3
# (phlco) atom won't support files over 2mb therefore we'll hold off.

brew cask install sublime-text
# ----------------------------------------------------------------------

# Our productivity suite
# ----------------------------------------------------------------------
# Our chat client
brew cask install slack

# Our window manager
brew cask install spectacle

# A screenshot sharing tool
brew cask install mac2imgur

# A clipboard enhancer
brew cask install jumpcut

# Flux, makes the color of your computer's display adapt to the time of day
# brew cask install flux

# An alternative terminal
# brew cask install iterm2
# ----------------------------------------------------------------------

# List of useful Quick Look plugins for developers
# See http://www.makeuseof.com/tag/quick-look-plugins-make-file-browsing-os-x-even-better/
# ----------------------------------------------------------------------
# brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json
# brew cask install qlprettypatch quicklook-csv betterzipql
# brew cask install webp-quicklook suspicious-package
# ----------------------------------------------------------------------

# The X Window Server
# ----------------------------------------------------------------------
# See:
#   - https://en.wikipedia.org/wiki/XQuartz
#   - https://support.apple.com/en-us/HT201341
# Cross-platform *nix window server, useful for a number of developer
# and open-source tools (Inkscape, Gimp, Meld, etc.)
brew cask install xquartz
# ----------------------------------------------------------------------

show "Complete!"

#-------------------------------------------------------------------------------
# Install Postgres (mac/postgres_install_hb.sh)
#-------------------------------------------------------------------------------

inform "Installing Postgres RDBMS via Homewbrew..." true
brew install postgresql
show "Complete!"


inform "Installing Ruby interface/genm for Postgres..." true
# from brew: "When installing the postgres gem, including ARCHFLAGS is
# recommended:"
ARCHFLAGS="-arch x86_64" gem install pg
show "Complete!"

inform "Creating Postgres data directory..." true
PGDATA="/usr/local/var/postgres"
initdb "$PGDATA" -E utf8
# TODO (PJ) set PGDATA env var in bash_profile?
show "Data directory initialized in ${PGDATA}"

inform "Attempting further configurations to ensure Postgres runs correctly..." true
# NOTE! https://coderwall.com/p/rjioeg
# Yosemite problems:
# for some reasons yosemite cleaned up some files/directories in /usr/local
# for postgres installed via homebrew the following directories were missing to
# start postgres properly:
sudo mkdir -p /usr/local/var/postgres/{pg_tblspc,pg_twophase,pg_stat_tmp}
# May also need this.
sudo chmod -R 0700 /usr/local/var/postgres
sudo chown -R ${USER} /usr/local/var/postgres
show "Complete!"

inform "Setting Postgres to launch at login..." true
mkdir -p ~/Library/LaunchAgents
cp /usr/local/Cellar/postgresql/9.*/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/
show "Complete!"


inform "Starting Postgres now..." true
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
# give postgres time to load
sleep 5s
show "Complete!"

inform "Creating a default user for Postgres..." true
# create db matching user name so we can log in by just typing psql
createdb ${USER}
show "Complete!"

# ------------------------------------------------------------------------------
# Final OS-specific Mac tweeks (mac/os_configure.sh)
# ------------------------------------------------------------------------------

inform "Setting OS configurations..." true

# # Disable the "Are you sure you want to open this application?" dialog
# defaults write com.apple.LaunchServices LSQuarantine -bool false

# Reveal IP address, hostname, OS version, etc. when clicking the clock
# in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Disable the warning when changing a file extension
sudo defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Only use UTF-8 in Terminal.app
sudo defaults write com.apple.terminal StringEncodings -array 4

show "Complete!"

# ------------------------------------------------------------------------------
# Clone the script repo locally in order to copy dotfiles etc. directly from it.
# (settings/script_repo_clone.sh)
# ------------------------------------------------------------------------------

inform "Downloading the Installfest repo, in order to copy files..." true
# download the repo for the absolute paths

if [[ $OS_VERSION == *10.6** ]]; then
  # 10.6 doesn't have git so download the zip and rename it installfest
  curl -LO https://github.com/ga-instructors/installfest_script/archive/$SCRIPT_REPO_BRANCH.zip
  unzip $SCRIPT_REPO_BRANCH.zip -d "$SCRIPT_ROOT"
  mv "$SCRIPT_ROOT/installfest-$SCRIPT_REPO_BRANCH/" "$SCRIPT_DIR"
else
  if [[ ! -d $SCRIPT_DIR ]]; then
    # autoupdate bootstrap file
    git clone -b $SCRIPT_REPO_BRANCH $SCRIPT_REPO $SCRIPT_DIR
  else
    # update repo
    echo 'Repo already downloaded; updating...'
    cd $SCRIPT_DIR
    git pull origin $SCRIPT_REPO_BRANCH
  fi
fi

show "Repo downloaded!"

#-------------------------------------------------------------------------------
# Define a utility function to copy over files (settings/util_copy_files.sh)
#-------------------------------------------------------------------------------

function copy_files () {
  # params
  local TYPE_DIR="$1"
  local TARGET_DIR="$2"
  local FILE_LIST="$3"

  # placeholder vars
  local CURRENT_FILE=""
  local TARGET_FILE=""
  local BACKUP_FILE=""
  local DOTFILES=""
  local BACKED_UP=""
  local PRINT_LN=""

  local TIMESTAMP=$(date +%s)
  local PAD="                                       "
  local BACKUP_DIR="${SCRIPT_ROOT}/${TYPE_DIR}_backups_${TIMESTAMP}"

  # check if the type of files is dotfiles
  if [[ "$TYPE_DIR" == "dotfiles" ]]; then
    DOTFILES=true
  fi

  for FILE_PATH in $FILE_LIST; do
    CURRENT_FILE=$(basename "$FILE_PATH")
    if [[ "$DOTFILES" == true ]]; then
      CURRENT_FILE=".$CURRENT_FILE" # add a dot to dotfiles
    fi

    # skip NOT-USING files
    if [[ ! $CURRENT_FILE == *"NOT-USING"* ]]; then

      # print a formatted line describing
      PRINT_LN="Copying file $CURRENT_FILE... "
      printf "%s %s" "$PRINT_LN" "${PAD:${#PRINT_LN}}"

      TARGET_FILE="${TARGET_DIR}/${CURRENT_FILE}"
      BACKUP_FILE="${BACKUP_DIR}/${CURRENT_FILE}"

      # back up files already in the target dir
      if [[ -e "$TARGET_FILE" ]]; then
        printf "(File exists! Backing up...)"
        BACKED_UP=true # save for a final message below

        # ensure the backup dir exists
        mkdir -p "$BACKUP_DIR"
        cp "$TARGET_FILE" "$BACKUP_FILE"
      fi

      # copy the file!
      cp "$FILE_PATH" "$TARGET_FILE"

      echo "" # flush printed line
    fi
  done

  if [[ "$BACKED_UP" == true ]]; then
    echo "${BOLD}Note: you can find backed-up files in ${BACKUP_DIR}${RESET}"
  fi
}

# Usage:
# copy_files dotfiles "$HOME" "$(echo $SCRIPT_DOTFILES)"
# copy_files themes "$HOME/Desktop" "TommorrowNight.theme"

#-------------------------------------------------------------------------------
# Copy over dotfiles (settings/copy_dotfiles.sh)
#-------------------------------------------------------------------------------

inform "Copying over configuration and preference files (dotfiles)..." true
copy_files "dotfiles" "$HOME" "$(echo $SCRIPT_DOTFILES)"
show "Complete!"

#-------------------------------------------------------------------------------
# Copy over the terminal theme (settings/copy_terminal_theme.sh)
#-------------------------------------------------------------------------------

inform "Copying terminal theme to Desktop..." true
copy_files themes "$HOME/Desktop" "$SCRIPT_SETTINGS/terminal/TomorrowNight.terminal"
show "Complete!"

#-------------------------------------------------------------------------------
# Copy over Sublime settiings & packages (settings/sublime_settings_settings.sh)
#-------------------------------------------------------------------------------

SUBLIME_DIR="${HOME}/Library/Application Support/Sublime Text 3"
SUBLIME_SETTINGS_DIR="${SUBLIME_DIR}/Packages/User"

# ensure files exist before copying
mkdir -p "$SUBLIME_SETTINGS_DIR"

inform "Copying Sublime settings..." true
copy_files subl_settings "$SUBLIME_SETTINGS_DIR" "$SCRIPT_SUBL_SETTINGS"
show "Complete!"

#-------------------------------------------------------------------------------
# Copy and install Subl packages (settings/copy_install_sublime_packages.sh)
#-------------------------------------------------------------------------------

SUBLIME_DIR="${HOME}/Library/Application Support/Sublime Text 3"
SUBLIME_PACKAGES_DIR="${SUBLIME_DIR}/Installed Packages"
SUBLIME_SETTINGS_DIR="${SUBLIME_DIR}/Packages/User"

# ensure files exist before copying
mkdir -p "$SUBLIME_PACKAGES_DIR"
mkdir -p "$SUBLIME_SETTINGS_DIR"

inform "Copying Sublime packages..." true
copy_files subl_packages "$SUBLIME_SETTINGS_DIR" "$SCRIPT_SUBL_PACKAGES"
show "Complete!"

# TODO (pj) get Package Control up and running with settings, etc.

# Install Package Control

PKG_CNTRL_URI="https://packagecontrol.io/Package%20Control.sublime-package"
PKG_CNTRL_FILE="Package Control.sublime-package"

# # NOTE (phlco) curling then mving because curl gave a malformed url in 10.6
# mkdir -p "$SRC_DIR/../packages"
# curl -O "$SRC_DIR/../packages" $PKG_CNTRL_URI
# mv "$SRC_DIR/../packages" "$SUBLIME_PACKAGES_DIR/$PKG_CNTRL_FILE"

inform "Downloading Sublime Package Control..." true
curl -o "${SUBLIME_PACKAGES_DIR}/$PKG_CNTRL_FILE" $PKG_CNTRL_URI
show "Complete!"

#-------------------------------------------------------------------------------
# Install the cross-platform fonts (mac/os_install_fonts.sh)
#-------------------------------------------------------------------------------

# Mac OS X used to use Monaco by default in ST, but now uses Menlo.
# While Menlo works fine, it is OS X only, and is not the best choice.
# Thus we've included 3 or 4 cross-platform choices:
#
# http://www.slant.co/topics/67/~what-are-the-best-programming-fonts
# http://hivelogic.com/articles/top-10-programming-fonts
#
# 1.  Source Code Pro (OTF/TTF) — https://github.com/adobe-fonts/source-code-pro
#     Open-source and created by Adobe, this is the premier monospace
#     font. It is the preferred choice for the students (easiest to
#     read at small sizes).
# 2.  DejaVu Sans Mono (TTF) — http://dejavu-fonts.org/wiki/Main_Page
#     Open-source and created for the Linux community, this font is
#     very nice and compares well to Source Code Pro (SCP). Use on
#     Linux if SCP renders poorly.
# 3.  (Linux) Monaco (TTF) — https://github.com/cstrap/monaco-font
#     Not clear on licensing. Monaco is very similar to Menlo, and is
#     simple and clean - many students prefer it. Thus, if using
#     Menlo instead of SCP on Mac, switch Mac to Monaco and Linux to
#     Monaco in order to keep the look & feel similar.
# 4.  Inconsolata (TTF) — https://www.google.com/fonts/specimen/Inconsolata
#     Open-source and created to be similar to the MS font Consolas.
#     A great programming font included in case students are used to
#     programming with Consolas (in MS) or want another choice.
#
# The Installfest is currently using the versions:
#
# - Source Code Pro:  v2.010
# - DejaVu Sans Mono: v2.35
# - (Linux) Monaco:   ???
# - Inconsolata:      v1.014

MAC_FONTS="source-code-pro dejavu-sans-mono inconsolata"

inform "Copying preferred programming fonts..." true

for FONT_ZIP in $SCRIPT_FONTS; do
  for MAC_FONT in $MAC_FONTS; do
    if [[ $FONT_ZIP == *"$MAC_FONT"* ]]; then
      FONT_DIR="${SCRIPT_FONTS%?}$MAC_FONT"

      unzip -q "$FONT_ZIP" -d "$FONT_DIR"

      OTF_FILE_LIST=$(find "$FONT_DIR" ! -type d | grep .otf$ | grep -v .woff | grep -v "._")
      TTF_FILE_LIST=$(find "$FONT_DIR" ! -type d | grep .ttf$ | grep -v .woff | grep -v "._")

      if [ -n "$OTF_FILE_LIST" ]; then
        copy_files fonts_otf "${HOME}/Library/Fonts" "$OTF_FILE_LIST"
      else
        copy_files fonts_ttf "${HOME}/Library/Fonts" "$TTF_FILE_LIST"
      fi

      rm -rf "$FONT_DIR"
    fi
  done
done

show "Complete!"



# code_dir_create.sh

inform "Creating directory for wdi: $STUDENT_FOLDER" true
mkdir -p $STUDENT_FOLDER
show "Complete!"

#-------------------------------------------------------------------------------
# We're done! (utils/script_footer.sh)
#-------------------------------------------------------------------------------

inform "We're done!" true
echo "#-- fin -- #"

fail "Please close your terminal and open a new one!" true
echo ""
