ar-settings
===========

My settings and scripts. The `install.sh` files should do the right thing when
provisioning a new machine.

Slowly this is moving to a more modular approach where the distribution can
either be Ubuntu or Manjaro.

## Bootstrap

### Prerequisites

#### Packages

For `Arch Linux`, the following dependencies are probably already installed and the bootstrap scripts will install the rest:

```shell
yay -Sy pinentry gnupg
```

The other (optional) program you want is [yay](https://github.com/Jguer/yay):

```shell
sudo pacman -S --needed git gnupg base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
```

#### Commands

```shell
mkdir ~/.gnupg && chmod 700 ~/.gnupg
```

To route prompts to the right pinentry backend (Emacs, terminal, or
graphical), copy the dispatcher to a directory on `PATH`:

```shell
cp usr/local/bin/pinentry-dispatch /usr/local/bin/
```

Then set `pinentry-program` to that path in `~/.gnupg/gpg-agent.conf` by
hand and reload the agent:

```shell
gpgconf --kill gpg-agent
```

The dispatcher routes a prompt by the `PINENTRY_USER_DATA` hint:

| Hint | Backend |
| --- | --- |
| `emacs` | `pinentry-emacs` |
| `curses` | `pinentry-curses` |
| `gtk` | `pinentry-gtk` |
| `mac` | `pinentry-mac` |
| `qt` | `pinentry-qt` |

The backend must be on `PATH`. A missing backend stops the prompt with an
error. With no hint, the dispatcher uses `pinentry-gtk` when `DISPLAY` or
`WAYLAND_DISPLAY` is set, else `pinentry-tty`.

macOS users must set the hint to get the native dialog:

```shell
export PINENTRY_USER_DATA=mac
```

The process that invokes `gpg` reads this variable, not the agent. The
export covers terminal use. Set it in the environment of each GUI app
(Emacs.app, IntelliJ, and others) that must show the dialog.

### Running

```shell
mkdir tmp
git clone https://github.com/arichiardi/ar-settings.git
```

#### Launch bootstrap scripts

Make the numbered files in bin executable and then run them in order

```shell
cd ar-settings/bootstrap

find bin -type l -regex '.*[0-9]+.*' -exec chmod u+x {} ';'
./bin/01-...
./bin/02-...
```

### Initialization

One bootstrapped, you can remove `tmp/ar-settings` and start working off of the main `git/ar-settings` dir.

The following scripts are going to initialize your distro.

```shell
cd ~/git/ar-settings

cd initialize
./bin/01-...
```

### Emacs.d

The `.emacs.d` folder can be cloned with:

``` shell
cd ~/.config
git clone git@github.com:arichiardi/emacs.d.git emacs
```

Then follow the instructions in the [README](https://github.com/arichiardi/emacs.d/blob/master/README.md).

## Secrets

You should not know where we store the secrets but they are in this repo, as encrypted files.
