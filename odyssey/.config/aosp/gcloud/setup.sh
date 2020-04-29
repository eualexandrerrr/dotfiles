#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

# Create folders
mkdir -p $HOME/.ccache
mkdir -p $HOME/.pull_rebase

# Install git-lfs
sudo apt-get install git-lfs zsh zsh-syntax-highlighting

# akhilnarang scripts
cd $HOME
git clone https://github.com/akhilnarang/scripts && cd scripts
bash setup/android_build_env.sh
cd .. && rm -rf scripts

# Start git lfs
git-lfs install

# Config repo and others
rm -rf $HOME/.bin && mkdir $HOME/.bin
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > $HOME/.bin/repo
ln -s /bin/python3.8 $HOME/.bin/python
chmod a+x $HOME/.bin/repo

rm -rf $HOME/.zshrc && cd $HOME && wget https://raw.githubusercontent.com/mamutal91/dotfiles/master/odyssey/.config/aosp/gcloud/.zshrc

# oh-my-zsh
# rm -rf $HOME/.oh-my-zsh && rm -rf $HOME/.zshrc && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
