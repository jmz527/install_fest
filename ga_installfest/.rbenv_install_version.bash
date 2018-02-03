#!/bin/bash

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
