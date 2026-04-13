ar-settings
===========

My settings and scripts. The `install.sh` files should do the right thing when
provisioning a new machine.

Slowly this is moving to a more modular approach where the distribution can
either be Ubuntu or Manjaro.

## Bootstrap

### Prerequisites

#### Packages

#### Packages

For `Arch Linux`, not many dependencies are need as the bootstrap scripts will install the rest:

```shell
yay -Sy pinentry
```

The other (optional) program you want is [yay](https://github.com/Jguer/yay):

```shell
sudo pacman -S --needed git gnupg base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
```

#### Commands

```shell
echo 'pinentry-program /usr/bin/pinentry-tty' >> ~/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye
```

### Running

```shell
mkdir tmp
git clone https://github.com/arichiardi/ar-settings.git
```

#### Launch bootstrap scripts

Make the numbered files in bin executable and then run them in order

```shell
cd bootstrap

find bin -type l -regex '.*[0-9]+.*' -exec chmod u+x {} ';'
./bin/01-...
./bin/02-...
```

### Emacs.d

The `.emacs.d` folder can be cloned with:

``` shell
cd .config
git clone git@github.com:arichiardi/emacs.d.git emacs
```

Then follow the instructions in the [README](https://github.com/arichiardi/emacs.d/blob/master/README.md).
```

## Secrets

You should not know where we store the secrets but they are in this repo, as encrypted files.
