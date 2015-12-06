#!/bin/bash

# If on OSX
if [[ $OSTYPE =~ ^darwin ]]; then
	echo "OS Type OS X Darwin Detected.  Bootstrapping OSX."

	# Download and install command line tools
	if [[ $(xcode-select -p > /dev/null 2>&1) ]]; then
		echo "Info    | Install    | xcode"
		xcode-select --install
	else
		echo "Info    | Already Installed    | xcode"
	fi

	# Download and install homebrew
	if [[ ! -x /usr/local/bin/brew ]]; then
		echo "Info    | Install    | Homebrew"
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		export PATH=/usr/local/bin:$PATH
	else
		echo "Info    | Already Installed    | Homebrew"
	fi
fi
