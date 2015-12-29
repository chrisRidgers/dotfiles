#!/bin/bash

function update_dotfiles_repo() {
    cd "$(dirname "${BASH_SOURCE}")"

    git pull origin master
}

function export_dotfiles() {
    rsync --exclude ".git" --exclude ".DS_Store" --exclude "bootstrap.sh" \
    --exclude "README.md" -avh --no-perms . ~
}

function osx_bootstrap() {
# Download and install command line tools
if [[ $(xcode-select -p 2>&1 > /dev/null) ]];then
    echo "Info    | Install    | xcode"
    xcode-select --install
else
    echo "Info    | Already Installed    | xcode"
fi

# Download and install homebrew
if [[ ! -x /usr/local/bin/brew ]];then
    echo "Info    | Install    | Homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    echo "Info    | Already Installed    | Homebrew"
fi

if [[ ! $PATH =~ /usr/local/bin ]];then
    echo 'Info    | Appending /usr/local/bin to $PATH    | Homebrew'
    export PATH=/usr/local/bin:$PATH
else
    echo 'Info    | /usr/local/bin already on $PATH    | Homebrew'
fi

# Configure OSX Defaults
read -p "Configure OSX using .osx? (y/n)" -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]];then
    echo "Info    | Not configuring OSX    | .osx"
else
    echo "Info    | Configuring OSX    | .osx"
    . $HOME/.osx
fi

# Install Zsh
if [[ ! -x /usr/local/bin/zsh ]];then
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
if [[ ! -x /usr/local/bin/git ]];then
    echo "Info   | Install   | git"
    brew install git
else
    echo "Info    | Already Installed    | git"
fi

# Download and install python
if [[ ! -x /usr/local/bin/python ]];then
    echo "Info   | Install   | python"
    brew install python --framework --with-brewed-openssl
else
    echo "Info    | Already Installed    | python"
fi

# Download and install Ansible
if [[ ! -x /usr/local/bin/ansible ]];then
    echo "Info    | Install    | ansible"
    sudo pip install ansible
else
    echo "Info    | Already Installed    | ansible"
fi
}

function osx_ansible() {
    ANSIBLE_PROVISIONING_URL='https://ChrisRidgers@bitbucket.org/ChrisRidgers/bootstrap.git'
    ANSIBLE_PROVISIONING_REPO="$HOME/.ansible-provision"

    echo "Info    | Downloading porvisioning repo over https, password can be found in 1password | ansible"
    if [[ ! -d $ANSIBLE_PROVISIONING_REPO ]];then
        echo "Info    | Cloning down the Mashbo Provisioning Repo    | ansible"
        git clone $ANSIBLE_PROVISIONING_URL $ANSIBLE_PROVISIONING_REPO
        (cd $ANSIBLE_PROVISIONING_REPO && git submodule init && git submodule update)
	echo "Info    | Remember to add this devices public ssh key to the bitbucket repo via the web interface | ansible"
    else
	echo "Info    | Updating the provision repo		     | ansible"
	(cd $ANSIBLE_PROVISIONING_REPO && git checkout master && git pull && git submodule update)
    fi

# Ansible Stuff
ansible-playbook -i $ANSIBLE_PROVISIONING_REPO/inventories/local-inventory $ANSIBLE_PROVISIONING_REPO/developer.yml --connection=local
}

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until boostrap has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

update_dotfiles_repo

if [ "$1" == "--force" -o "$1" == "-f" ];then
	export_dotfiles
else
	read -p "This may overwrite existing files in your home directory.  Are you sure? (y/n) " -n 1
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]];then
       export_dotfiles
   fi
fi

# If on OSX
if [[ $OSTYPE =~ ^darwin ]];then
    echo "OS Type OS X Darwin Detected.  Bootstrapping OSX."
    osx_bootstrap
    osx_ansible
fi
unset update_dotfiles_repo
unset export_dotfiles
unset osx_bootstrap
unset osx_ansible

