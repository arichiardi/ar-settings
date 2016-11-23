#!/usr/bin/env bash

LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
NC='\033[0m' # No Color

SSH_DIR=$HOME/.ssh

echo -e "${LIGHT_GREEN}Copying bin scripts...${NC}"
mkdir -p $HOME/bin
cp -Riv bin/. $HOME/bin

echo -e "${LIGHT_RED}Copying etc folder...${NC}"
sudo cp -Riv etc/. /etc

echo -e "${LIGHT_RED}Copying dot files...${NC}"
cp -Riv dotfiles/. $HOME

echo -e "${LIGHT_GREEN}Deploying GPG key...${NC}"
mkdir -p $SSH_DIR
bin/restoresecret.sh $SSH_DIR/5BB502F6_rsa.enc $SSH_DIR/5BB502F6_rsa
chmod 600 $SSH_DIR/*

echo -e "${LIGHT_GREEN}Installing packages...${NC}"
sudo apt-get install rxvt-unicode i3 rofi qasmixer scrot cmake arandr silversearcher-ag zeal

echo -e "${LIGHT_GREEN}Installing cask...${NC}"
curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python
ln -s $HOME/.cask/bin/cask $HOME/bin/cask

echo -e "${LIGHT_GREEN}Installing fonts and refreshing cache...${NC}"
mkdir -p $HOME/.fonts
cp -Riv fonts/. $HOME/.fonts
fc-cache -rv
