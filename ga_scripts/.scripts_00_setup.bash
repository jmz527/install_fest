#!/bin/bash

#-------------------------------------------------------------------------------
# Set up basic env vars
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
# Set text formatting
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
# Logging
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
  echo -e "${WHITE}> $* ${RESET}"
}

function inform () {
  if [[ $2 ]]; then echo ""; fi
  echo -e "${GREEN}${BOLD}>>>>  $1 ${RESET}"
}

function warn () {
  if [[ $2 ]]; then echo ""; fi
  echo -e "${YELLOW}${BOLD}>>>>  $1 ${RESET}"
}

function fail () {
  if [[ $2 ]]; then echo ""; fi
  echo -e "${RED}${BOLD}>>>>  $1 ${RESET}"
}

function pause_awhile () {
  if [[ $2 ]]; then echo ""; fi
  echo -e "${YELLOW}${BOLD}>>>>  $1 ${RESET}"
  read -p "${YELLOW}${BOLD}Press <Enter> to continue.${RESET}"
}

function pause_and_warn () {
  if [[ $2 ]]; then echo ""; fi
  echo -e "${YELLOW}${BOLD}>>>>  $1 ${RESET}"
  echo -e "${YELLOW}${BOLD}>>>> ${RESET}"
  read -p "${YELLOW}${BOLD}>>>>  Continue? [Yy] ${RESET} " -n 1 -r

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    fail "Exiting..." true
    exit 1;
  fi
}

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
# Print it all
#-------------------------------------------------------------------------------


# # Print out file variables
# DESCRIPTION=`cat << EOFS
#   BELOVED_RUBY_VERSION:           "$BELOVED_RUBY_VERSION"
#   CURRENT_STABLE_RUBY_VERSION:    "$CURRENT_STABLE_RUBY_VERSION"
#   BELOVED_PYTHON_VERSION:         "$BELOVED_PYTHON_VERSION"
#   CURRENT_STABLE_PYTHON_VERSION:  "$CURRENT_STABLE_PYTHON_VERSION"
#   NODE_VERSION:                   "$NODE_VERSION"
#   OSTYPE:                         "$OSTYPE"
#   SYSTEM:                         "$SYSTEM"
#   BASH_FILE:                      "$BASH_FILE"
#   MINIMUM_MAC_OS:                 "$MINIMUM_MAC_OS"
#   SCRIPT_ROOT:                    "$SCRIPT_ROOT"

#   COLORTERM:    "$COLORTERM"
#   TERM:         "$TERM"
#   BLACK:        "${BLACK} - BLACK"
#   RED:          "${RED} - RED"
#   GREEN:        "${GREEN} - GREEN"
#   YELLOW:       "${YELLOW} - YELLOW"
#   BLUE:         "${BLUE} - BLUE"
#   MAGENTA:      "${MAGENTA} - MAGENTA"
#   CYAN:         "${CYAN} - CYAN"
#   WHITE:        "${WHITE} - WHITE"
#   BG_BLACK:     "${BG_BLACK} - BG_BLACK"
#   BG_RED:       "${BG_RED} - BG_RED"
#   BG_GREEN:     "${BG_GREEN} - BG_GREEN"
#   BG_YELLOW:    "${BG_YELLOW} - BG_YELLOW"
#   BG_BLUE:      "${BG_BLUE} - BG_BLUE"
#   BG_MAGENTA:   "${BG_MAGENTA} - BG_MAGENTA"
#   BG_CYAN:      "${BG_CYAN} - BG_CYAN"
#   BG_WHITE:     "${BG_WHITE} - BG_WHITE"
#   UNDERLINE:    "${UNDERLINE} - UNDERLINE"
#   NOUNDERLINE:  "${NOUNDERLINE} - NOUNDERLINE"
#   BOLD:         "${BOLD} - BOLD"
#   ITALIC:       "${ITALIC} - ITALIC"
#   RESET:        "${RESET} - RESET"
# EOFS`

# inform "File variables:"
# printf "$DESCRIPTION\n"
