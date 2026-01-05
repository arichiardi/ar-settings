ar-settings
===========

My settings and scripts. The `install.sh` files should do the right thing when
provisioning a new machine.

Slowly this is moving to a more modular approach where the distribution can
either be Ubuntu or Manjaro.

### Bootstrap

#### Install yay

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

#### Use pinentry-tty

yay -S pinentry

echo 'pinentry-program /usr/bin/pinentry-tty' >> ~/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye

#### Launch bootstrap

Make the numbered files in bin executable and then run them in order

find bin -type l -regex '.*[0-9]+.*' -exec chmod u+x {} ';'
./bin/01
./bin/02

### Emacs.d

The `.emacs.d` folder can be cloned with:

``` shell
$ git clone git@github.com:arichiardi/emacs.d.git
```

Then follow the instructions in the [README](https://raw.githubusercontent.com/arichiardi/emacs.d/master/README.md).

For further customization bonanza clone:

``` shell
$ git clone git@github.com:arichiardi/ar-emacs-pack.git

$ cat > ~/.emacs-live.el
(live-append-packs '(~/.live-packs/ar-emacs-pack))
^D
```

### Secrets

You should not know where we store the secrets but they are in this repo, as encrypted files.
