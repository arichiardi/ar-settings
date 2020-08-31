ar-settings
===========

My settings and scripts. The `install.sh` files should do the right thing when
provisioning a new machine. It requires connection for downloading things and
it assumes a distro where `apt` and `snap` are available (Ubuntu).

Slowly this is moving to a more modular approach where the distribution can
either be Ubuntu or Manjaro.

### Compile emacs

If you want to compile emacs you need to clone is first and then execute:

```
./configure --with-json --with-x-toolkit=gtk3 --with-cairo --with-xwidgets --enable-gtk-deprecation-warnings  \
  --with-gif=ifavailable --with-jpeg=ifavailable --with-png=ifavailable --with-tiff=ifavailable --with-gnutls=no \
  --enable-checking=structs --with-x --without-pop \
  --prefix "$HOME/.local"
make
make install
```

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

The secret dotfiles are stored in an encrypted [Keybase](https://keybase.io/) repository:

``` shell
git clone keybase://private/arichiardi/ar-secret-settings
```
