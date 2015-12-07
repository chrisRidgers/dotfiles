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
	else
		echo "Info    | Already Installed    | Homebrew"
	fi

	if [[ ! $PATH =~ /usr/local/bin ]]; then
		echo 'Info    | Appending /usr/local/bin to $PATH    | Homebrew'
		export PATH=/usr/local/bin:$PATH
	else
		echo 'Info    | /usr/local/bin already on $PATH    | Homebrew'
	fi

	# Configure OSX Defaults
	read -p "Configure OSX using .osx? (y/n)" -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		echo "Info    | Not configuring OSX    | .osx"
	else
		echo "Info    | Configuring OSX    | .osx"
		. .osx
	fi

	# Install Zsh
	if [[ ! -x /usr/local/bin/zsh ]]; then
		echo "Info    | Install    | Zsh"
		brew install zsh
	else
		echo "Info    | Already Installed    | Zsh"
	fi

	if [[ ! "grep -Fxq '/usr/local/bin/zsh' /etc/shells" ]];then
		echo "Info    | Appending zsh to /etc/shells    | Zsh"
		echo '/usr/local/bin/zsh' | sudo tee -a /etc/shells
	else
		echo "Info    | Zsh already exists in /etc/shells    | Zsh"
	fi

	sudo chsh -s /usr/local/bin/zsh $USER

	# Install Oh My ZSH
	if [[ ! -d ~/.oh-my-zsh ]];then
		echo "Info    | Install    | Oh My ZSH"
		sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	else
		echo "Info    | Already Installed    | Oh My ZSH"
	fi
fi
