#!/bin/zsh

brew analytics off
rustup default stable
rustup component add rust-analyzer
echo /run/current-system/sw/bin/fish | sudo tee -a /etc/shells
chsh -s /run/current-system/sw/bin/fish 
ln -s ~/github/dotfiles/functions/ ~/.config/fish/
