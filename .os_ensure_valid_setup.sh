#!/bin/sh

# import utility methods
. ./.utilities.sh

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

DESCRIPTION="
       Short user name: $USER_NAME
       Long user name:  $FULL_NAME
       IP address:  $MAC_ADDRS
";

inform "Loading your computer's information..." true
inform "Your current setup is:" true
./.archey.sh -o
printf "$DESCRIPTION\n"
echo "";
pause_and_warn "Does this all look correct to you?"
echo "";
inform "Checking the validity of this setup. If it is not valid, script will fail or warn you." true
echo "";
# Check if current user is admin.
if echo "$USER_GRPS" | grep -q -w admin; then
  echo "" > /dev/null
else
  fail "The current user does not have administrator privileges. You must " true
  fail "  run this program from an admin user. Ask a manager for help."
  fail "Exiting..." true
  exit 1
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
  echo "";
  pause_and_warn "PS: this also goes for your GitHub username!"
fi
echo "Setup is valid!"
echo "";
