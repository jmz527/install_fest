#!/usr/bin/env bash

# rvm ruby and rails
\curl -sSL https://get.rvm.io | bash -s stable -ruby -rails
source /Users/jamesrutledge/.rvm/scripts/rvm


# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
