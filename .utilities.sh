#!/bin/sh

#-------------------------------------------------------------------------------
# Colors
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
# Methods
#-------------------------------------------------------------------------------
show () {
  if [ $2 ]; then echo ""; fi
  echo "${WHITE}$1${RESET}"
}

inform () {
  if [ $2 ]; then echo ""; fi
  echo "${CYAN}$1${RESET}"
}

warn () {
  if [ $2 ]; then echo ""; fi
  echo "${YELLOW}$1${RESET}"
}

fail () {
  if [ $2 ]; then echo ""; fi
  echo "${RED}$1${RESET}"
}

pause_awhile () {
  if [ $2 ]; then echo ""; fi
  echo "${YELLOW}>>>>  $1 ${RESET}"; echo "";
  echo "${YELLOW}Press <Enter> to continue.${RESET}"
  read -p ""
}

pause_and_warn () {
  if [ $2 ]; then echo ""; fi
  echo -e "${YELLOW}${BOLD}>>>>  $1 ${RESET}"
  echo -e "${YELLOW}${BOLD}>>>> ${RESET}"
  read -p "${YELLOW}${BOLD}>>>>  Continue? [Yy] ${RESET} " -n 1 -r

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    fail "Exiting..." true
    exit 1;
  fi
}

checkForCommand () {
  if ! [ -x "$(which $1)" ]; then
    fail "Error: $1 is not installed." >&2
    exit 1
  fi
}

checkForFile () {
  if [ ! -f $1 ]; then
    fail "Error: $1 file not found." >&2
    exit 1
  fi
}

checkForDirectory () {
  if [ ! -d $1 ]; then
    fail "Error: $1 directory not found." >&2
    exit 1
  fi
}
