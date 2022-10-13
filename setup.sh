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

cd "$DOTPATH"

# install Homebrew
if !(type brew > /dev/null 2>&1); then
    yes | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $HOME/.profile
    echo 'eval "$(rbenv init - bash)"' >> $HOME/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    . $HOME/.profile
    echo
fi

# update Homebrew
brew update && brew outdated && brew upgrade && brew cleanup

# bundle for common
brew bundle

echo "Setup finished!"
