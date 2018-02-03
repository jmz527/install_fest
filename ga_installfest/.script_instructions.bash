#!/bin/bash

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

sudo -p "Password:" echo "${WHITE}> Thank you! ${RESET}"

# mac/os_version.sh

# Determine OS version
OS_VERSION=$(sw_vers -productVersion)