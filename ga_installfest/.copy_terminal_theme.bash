#!/bin/bash

inform "Copying terminal theme to Desktop..." true
copy_files themes "$HOME/Desktop" "$SCRIPT_SETTINGS/terminal/TomorrowNight.terminal"
show "Complete!"
