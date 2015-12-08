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

	# Download and install git
	if [[ ! -x /usr/local/bin/git ]]; then
		echo "Info   | Install   | git"
		brew install git
	else
		echo "Info    | Already Installed    | git"
	fi

	# Download and install python
	if [[ ! -x /usr/local/bin/python ]]; then
		echo "Info   | Install   | python"
		brew install python --framework --with-brewed-openssl
	else
		echo "Info    | Already Installed    | python"
	fi

	# Download and install Ansible
	if [[ ! -x /usr/local/bin/ansible ]]; then
		echo "Info    | Install    | ansible"
		sudo pip install ansible
	else
		echo "Info    | Already Installed    | ansible"
	fi

	ANSIBLE_PROVISIONING_URL='https://ChrisRidgers@bitbucket.org/ChrisRidgers/bootstrap.git'
	ANSIBLE_PROVISIONING_REPO="$HOME/.ansible-provision"
	if [[ ! -d $ANSIBLE_PROVISIONING_REPO ]]; then
		echo "Info    | Cloning down the Mashbo Provisioning Repo    | ansible"
		git clone $ANSIBLE_PROVISIONING_URL $ANSIBLE_PROVISIONING_REPO
		(cd $ANSIBLE_PROVISIONING_REPO && git submodule init && git submodule update)
	fi

	# Ansible Stuff
	ansible-playbook --ask-sudo-pass -i $ANSIBLE_PROVISIONING_REPO/inventories/local-inventory $ANSIBLE_PROVISIONING_REPO/developer.yml --connection=local
fi
