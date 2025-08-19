ar-settings
===========

My settings and scripts. The `install.sh` files should do the right thing when
provisioning a new machine.

Slowly this is moving to a more modular approach where the distribution can
either be Ubuntu or Manjaro.

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

### Hub OAuth Setup

To set up GitHub Hub CLI with OAuth authentication:

1. **Quick Setup**: Use the helper script:
   ```shell
   $ ./home/.local/bin/setup-hub-oauth --info  # Shows how to create GitHub token
   $ ./home/.local/bin/setup-hub-oauth         # Interactive setup
   ```

2. **Manual Setup**: See the [detailed guide](docs/hub-oauth-setup.md) for step-by-step instructions.

3. **Restore on New Machine**:
   ```shell
   $ ./home/.local/bin/secret --restore --src ./home/.config/hub.enc --dest ~/.config/hub
   ```

### Secrets

You should not know where we store the secrets but they are in this repo, as encrypted files.
