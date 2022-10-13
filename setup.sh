#!/bin/bash

set -eu

sudo apt -qq update
sudo apt -y upgrade
sudo apt install -yq build-essential
sudo apt autoremove

# set dotflies
DOTPATH=$HOME/dotfiles

if [ ! -d "$DOTPATH" ]; then
    git clone https://github.com/nashirox/wsl-dotfiles.git "$DOTPATH"
else
    echo "$DOTPATH already exists. Updating..."
    cd "$DOTPATH"
    git stash
    git checkout main
    git pull origin main
    echo
fi

cd $DOTPATH

# install Homebrew
if !(type brew > /dev/null 2>&1); then
    yes | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $HOME/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    . $HOME/.profile
    echo
fi

# update Homebrew
brew update && brew outdated && brew upgrade && brew cleanup

# bundle for common
brew bundle

cd $HOME

# install Docker
if !(type docker > /dev/null 2>&1); then
    sudo apt install -yq \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   echo \
       "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt -qq update
    sudo apt install -yq docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo
fi

# install latest Ruby
if !(type ruby > /dev/null 2>&1); then
    LATEST_RUBY_VERSION=$(rbenv install -l | grep -v - | tail -1)
    rbenv install $LATEST_RUBY_VERSION
    rbenv global $LATEST_RUBY_VERSION
    echo 'export PATH="/home/linuxbrew/.linuxbrew/bin/rbenv:$PATH"' >> $HOME/.profile
    echo 'eval "$(rbenv init - bash)"' >> $HOME/.profile
    . $HOME/.profile
    echo
fi

exec $SHELL
