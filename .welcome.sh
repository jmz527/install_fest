#!/bin/sh

# import utility methods
. ./.utilities.sh

echo "
${GREEN#   }     _____         _       _ _ ___         _
${YELLOW#  }    |     |___ ___| |_ ___| | |  _|___ ___| |_
${RED#     }    |-   -|   |_ -|  _| .'| | |  _| -_|_ -|  _|
${MAGENTA# }    |_____|_|_|___|_| |__,|_|_|_| |___|___|_|
${CYAN#    }                                 Setup Script
${RESET}
";

show "       Welcome to the Installfest Script!"; show "";

show ""
show "Throughout the script you will be asked to enter your password."
show "Unless otherwise stated, this is asking for your ${BOLD}computer's password. ${RESET}";
show ""
show "This script will install, update, and configure files and applications."

# capture the user's password
inform "Enter your computer's password so that we can make the necessary changes." true
inform "  The password will not be visible as you type."
show ""
sudo -p "Password:" echo "";
show "${BOLD}> Thank you! ${RESET}";
