#!/bin/bash

# Setup script for Archlinux based on archinstall
# 1. install base system going through archinstall
#     - copy iwd config for initial wifi/network setup
#     - minimal system install
# 2. run script in chroot

## Setup vars
HOSTNAME=`cat /etc/hostname`
USERNAME="john" # double check with `cat /etc/passwd | grep home | cut -d: -f1`
DOTFILES="/home/$USERNAME/.dotfiles"

# Get setup scripts

# Install packages
sudo pacman -Syy
sudo pacman -Syu

## system_base (in addition to archinstall base)
sudo pacman -S --noconfirm --needed vim git iwd curl screen htop openssh man-db wget cifs-utils unzip
## packages 
sudo pacman -S --noconfirm --needed snapd
## font 
sudo pacman -S --noconfirm --needed ttf-dejavu
## wm_related
#sudo pacman -S --noconfirm --needed sway alacritty termite
sudo pacman -S --noconfirm --needed xorg xorg-server xorg-xinit xorg-xdm xterm
sudo pacman -S --noconfirm --needed i3 i3lock dmenu
## machine drivers
## file viewer/management
sudo pacman -S --noconfirm --needed meld feh zathura ranger libreoffice vlc 
sudo pacman -S --noconfirm --needed firefox alsa pulseaudio-bluetooth

## start deamons
sudo systemctl enable xdm.service

# Dotfiles
## setup ssh key
mkdir -p /home/$USERNAME/.ssh/
ssh-keygen -t rsa -b 4096 -C "<your_email>" -f /home/$USERNAME/.ssh/id_rsa
eval $(ssh-agent -s)
ssh-add

## setup github credentials
curl -H 'Authorization: token <generated_token>' -H 'Accept: application/vnd.github.v3+json' https://api.github.com/user/keys -d "{\"title\":\"$HOSTNAME\",\"key\":\"`cat /home/$USERNAME/.ssh/id_rsa.pub`\"}"

## get dotfiles repo
git config --global user.email "<your_email>"
git config --global user.name "<your_name>"
git clone git@github.com:<github_username>/<github_repo_name>.git
chown -R $USERNAME $DOTFILES

## setup configs
ln -s $DOTFILES/X11/Xresources_home /home/$USERNAME/.Xresources
ln -s $DOTFILES/X11/xinitrc /home/$USERNAME/.xinitrc
sudo ln -s $DOTFILES/X11/00-keyboard.conf /etc/X11/xorg.conf.d/
sudo mv /etc/X11/xdm/Xresources /etc/X11/xdm/Xresources.bck
sudo ln -s $DOTFILES/X11/Xresources_xdm /etc/X11/xdm/Xresources
mkdir -p /home/$USERNAME/.config/i3
ln -s $DOTFILES/i3/config /home/$USERNAME/.config/i3/config
ln -s $DOTFILES/vim/vimrc /home/$USERNAME/.vimrc
ln -sf $DOTFILES/bash/bashrc /home/$USERNAME/.bashrc
ln -s $DOTFILES/bash/bash_aliases /home/$USERNAME/.bash_aliases

## keymap (tty swap escape)
sudo mkdir -p /usr/local/share/kbd/keymaps
sudo ln -s $DOTFILES/tty/de-latin1-john.map.gz /usr/local/share/kbd/keymaps
