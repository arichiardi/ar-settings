ar-settings
===========

My settings and scripts. The `install.sh` files should do the right thing when
provisioning a new machine. It requires connection for downloading things and
it assumes a distro where `apt` and `snap` are available (Ubuntu).

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

### Secrets

You should not know where we store the secrets but it is this repo, as encrypted files.
