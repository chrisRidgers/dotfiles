#!/bin/bash

# If on OSX
if [[ $OSTYPE =~ ^darwin ]]; then
	echo "OS Type OS X Darwin Detected.  Bootstrapping OSX."

	# Download and install command line tools
	if [[ $(xcode-select -p > /dev/null 2>&1) ]]; then
		echo "Info    | Install    | xcode"
		xcode-select --install
	fi
fi
