#!/usr/bin/env bash

set -euo pipefail

# For skipping sections, use this trick:
#
#   cat >/dev/null <<HUB
#
# see the brilliant answer here: https://stackoverflow.com/a/45538151

LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
NC='\033[0m' # No Color

SSH_DIR=$HOME/.ssh
TEMP_DIR=$(mktemp -d -t "ar-settings.XXXXXXXXXX")

echo -e "${LIGHT_GREEN}Create necessary dirs...${NC}"
mkdir -p $HOME/bin
mkdir -p $HOME/tmp
mkdir -p /tmp/vault

echo -e "${LIGHT_GREEN}Setting up vault dir...${NC}"
sudo chmod g+s /tmp/vault

echo -e "${LIGHT_GREEN}Copying bin scripts...${NC}"
cp -Riv bin/. $HOME/bin

echo -e "${LIGHT_RED}Copying etc folder...${NC}"
sudo cp -Riv etc/. /etc

echo -e "${LIGHT_RED}Copying dot files...${NC}"
cp -Riv dotfiles/. $HOME

echo -e "${LIGHT_GREEN}Deploying GPG key...${NC}"
mkdir -p $SSH_DIR
bin/restoresecret.sh $SSH_DIR/5BB502F6_rsa.enc $SSH_DIR/5BB502F6_rsa
chmod 600 $SSH_DIR/*

echo -e "${LIGHT_GREEN}Updating apt packages...${NC}"
sudo apt-get update

echo -e "${LIGHT_GREEN}Installing apt packages...${NC}"
sudo apt-get install rxvt-unicode i3 rofi qasmixer scrot cmake arandr silversearcher-ag zeal \
     xsel docker docker-compose exuberant-ctags openjdk-8-jdk openjdk-8-doc tree byzanz \
     rlwrap awscli markdown xclip xbacklight texinfo meld python3-pip cryptsetup global \
     exiftool cdiff texlive-latex-base texlive-latex-extra wicd-cli wicd-curses wich-gdk \
     console-data

echo -e "${LIGHT_GREEN}Installing apt emacs compilation packages...${NC}"
sudo apt install libgnutls28-dev libgtk-3-dev libwebkitgtk-3.0-dev # or libwebkit2gtk-4.0-dev

echo -e "${LIGHT_GREEN}Installing snap packages...${NC}"
sudo snap install keepassxc skype

echo -e "${LIGHT_GREEN}Installing cask...${NC}"
curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python
ln -si $HOME/.cask/bin/cask $HOME/bin/cask

echo -e "${LIGHT_GREEN}Installing leiningen...${NC}"
curl -o- https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein > $HOME/bin/lein
chmod +x $HOME/bin/lein

echo -e "${LIGHT_GREEN}Installing boot...${NC}"
curl -fsSLo- https://github.com/boot-clj/boot-bin/releases/download/latest/boot.sh > $HOME/bin/boot
chmod +x $HOME/bin/boot

echo -e "${LIGHT_GREEN}Installing diff-so-fancy...${NC}"
curl -o- https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy > $HOME/bin/diff-so-fancy
chmod +x $HOME/bin/diff-so-fancy

echo -e "${LIGHT_GREEN}Installing fonts and refreshing cache...${NC}"
mkdir -p $HOME/.fonts
cp -Riv fonts/. $HOME/.fonts
fc-cache -rv

echo -e "${LIGHT_GREEN}Installing nvm (Node Version Manager)...${NC}"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

echo -e "${LIGHT_RED}Installing Node.js...${NC}"
nvm install --lts && nvm use node

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

curl -o- https://raw.githubusercontent.com/github/hub/master/etc/hub.bash_completion.sh > $TEMP_DIR/hub
sudo cp -iv --no-preserve=mode,ownership $TEMP_DIR/hub /etc/bash_completion.d/hub
rm -fv $TEMP_DIR/hub

echo -e "${LIGHT_GREEN}Installing hub...${NC}"
cd $TEMP_DIR
curl -OL https://github.com/github/hub/releases/download/v2.3.0-pre10/hub-linux-amd64-2.3.0-pre10.tgz \
    && mkdir hub-deflated \
    && tar -C hub-deflated --strip-components=1 -xvzf hub-linux-amd64-2.3.0-pre10.tgz \
    && prefix="$HOME/.local" ./hub-deflated/install
