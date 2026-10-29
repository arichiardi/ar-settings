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
gpgconf --reload gpg-agent
```

You must reload the agent after you change `pinentry-program` or the
dispatcher. A running agent keeps the old setting, so the prompt keeps
using the old backend until the reload. `gpgconf --kill gpg-agent` also
works. It stops the agent, and the next `gpg` call starts it again.

The dispatcher routes a prompt by the `PINENTRY_USER_DATA` hint:

| Hint | Backend |
| --- | --- |
| `emacs` | `pinentry-emacs` |
| `curses` | `pinentry-curses` |
| `gtk` | `pinentry-gtk` |
| `mac` | `pinentry-mac` |
| `qt` | `pinentry-qt` |

The backend must be on `PATH`. A missing backend stops the prompt with an
error. A non-empty hint outside the table also stops the prompt with an
error, so a typo fails loudly. With no hint, the dispatcher uses
`pinentry-gtk` when `DISPLAY` or `WAYLAND_DISPLAY` is set, else
`pinentry-tty`.

macOS users must set the hint to get the native dialog:

```shell
export PINENTRY_USER_DATA=mac
```

The process that invokes `gpg` reads this variable, not the agent. The
export covers terminal use. Set it in the environment of each GUI app
(Emacs.app, IntelliJ, and others) that must show the dialog.

#### Git credentials

Git reads credentials from a GPG-encrypted netrc file through the upstream
`git-credential-netrc` helper. Initialize it with:

```shell
./init-git-netrc
```

The script pulls the helper into `/usr/local/bin` and creates or appends to
the per-user `~/.netrc.gpg`. Then enable it for your user:

```shell
git config --global credential.helper netrc
```

<details>
<summary>Manual setup and details</summary>

Enable the helper per user in `~/.config/git/config`:

```shell
git config --global credential.helper netrc
```

Pull the upstream helper by hand. Do not vendor a copy here. Pin the tag
to the local git version:

```shell
git_tag=v$(git --version | awk '{print $3}')
sudo curl -fsSL -o /usr/local/bin/git-credential-netrc \
    "https://raw.githubusercontent.com/git/git/${git_tag}/contrib/credential/netrc/git-credential-netrc.perl"
sudo chmod 755 /usr/local/bin/git-credential-netrc
```

Create the encrypted credentials file per user. One entry is one line. The
plaintext never touches disk:

```shell
gpg --encrypt --recipient <gpg-id> -o ~/.netrc.gpg - <<'EOF'
machine github.com protocol https login x-access-token password <token>
EOF
chmod 600 ~/.netrc.gpg
```

GitHub ignores the login for token auth. The token is the password.
The login stays `x-access-token`.

The helper auto-detects `~/.authinfo.gpg`, `~/.netrc.gpg`, `~/.authinfo`, and
`~/.netrc` in `$HOME`, in that order. The first matching `machine`/`login`
entry wins. The helper only supports `get`. The `--gpg <program>` flag
overrides the GPG program, and `-f <file>` adds an explicit file.

</details>

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

## WezTerm

The WezTerm config lives in `home/.config/wezterm/wezterm.lua` (moved from
the old `home/.wezterm.lua` location).

On Arch Linux, the config needs these fonts installed:

```shell
yay -S ttf-jetbrains-mono-nerd noto-fonts-cjk noto-fonts-emoji
```

- `ttf-jetbrains-mono-nerd` — primary font (JetBrainsMono Nerd Font Mono)
- `noto-fonts-cjk` — CJK glyph fallback (SC, JP, KR, TC)
- `noto-fonts-emoji` — color emoji

Optional extras: `ttf-nerd-fonts-symbols` and `ttf-nerd-fonts-symbols-common`
for additional nerd icon glyphs.

## Secrets

You should not know where we store the secrets but they are in this repo, as encrypted files.
