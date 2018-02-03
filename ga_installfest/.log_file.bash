#!/bin/bash


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