#!/bin/bash
# github.com/mamutal91

# Create folders
mkdir -p $HOME/.ccache
mkdir -p $HOME/.pull_rebase

sudo apt-get update && sudo apt-get upgrade -y

# Install packages needed
sudo apt-get install aria2 nginx zsh zsh-syntax-highlighting -y

# Instal git-lfs
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install git-lfs
git lfs install

# Enable nginx
sudo systemctl enable nginx && sudo systemctl start nginx

# akhilnarang scripts
cd $HOME

bash setup/android_build_env.sh
cd .. && rm -rf scripts

# Config repo and others
rm -rf $HOME/.bin && mkdir $HOME/.bin
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > $HOME/.bin/repo
ln -s /bin/python3.8 $HOME/.bin/python
chmod a+x $HOME/.bin/repo

rm -rf $HOME/.zshrc && cd $HOME && wget https://raw.githubusercontent.com/mamutal91/dotfiles/master/aspire/.config/aosp/gcloud/.zshrc

# oh-my-zsh
# rm -rf $HOME/.oh-my-zsh && rm -rf $HOME/.zshrc && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/mamutal91/dotfiles/master/aspire/.config/aosp/gcloud/setup.sh)"
