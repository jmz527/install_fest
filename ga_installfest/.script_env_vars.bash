#!/bin/bash

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
