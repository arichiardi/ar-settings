#!/usr/bin/env bash

LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
NC='\033[0m' # No Color

SSH_DIR=$HOME/.ssh
TEMP_DIR=$(mktemp -d -t)

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
sudo apt-get install rxvt-unicode i3 rofi qasmixer scrot cmake arandr silversearcher-ag zeal \
     xsel docker docker-compose exuberant-ctags openjdk-8-jdk openjdk-8-doc tree \
     rlwrap awscli markdown xclip xbacklight texinfo

echo -e "${LIGHT_GREEN}Installing cask...${NC}"
curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python
ln -s $HOME/.cask/bin/cask $HOME/bin/cask

echo -e "${LIGHT_GREEN}Installing leiningen...${NC}"
curl -o- https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein > $HOME/bin/lein
chmod +x $HOME/bin/lein

echo -e "${LIGHT_GREEN}Installing fonts and refreshing cache...${NC}"
mkdir -p $HOME/.fonts
cp -Riv fonts/. $HOME/.fonts
fc-cache -rv

echo -e "${LIGHT_GREEN}Installing nvm (Node Version Manager)...${NC}"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash
NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

echo -e "${LIGHT_RED}Installing Node.js...${NC}"
NPM_PACKAGES="$HOME/.local/share/npm-packages"
mkdir -p "$NPM_PACKAGES"
nvm install node
nvm use node
nvm alias default node

echo -e "${LIGHT_RED}Installing bash completions...${NC}"
curl -o- https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose > $TEMP_DIR/docker-compose
sudo cp -iv --no-preserve=mode,ownership $TEMP_DIR/docker-compose /etc/bash_completion.d/docker-compose
rm -fv $TEMP_DIR/docker-compose

curl -o- https://raw.githubusercontent.com/technomancy/leiningen/master/bash_completion.bash > $TEMP_DIR/lein
sudo cp -iv --no-preserve=mode,ownership $TEMP_DIR/lein /etc/bash_completion.d/lein
rm -fv $TEMP_DIR/lein

curl -o- https://raw.githubusercontent.com/creationix/nvm/master/bash_completion > $TEMP_DIR/nvm
sudo cp -iv --no-preserve=mode,ownership $TEMP_DIR/nvm /etc/bash_completion.d/nvm
rm -fv $TEMP_DIR/nvm

npm completion > $TEMP_DIR/npm
sudo cp -iv --no-preserve=mode,ownership $TEMP_DIR/npm /etc/bash_completion.d/npm
rm -fv $TEMP_DIR/npm
