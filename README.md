ar-settings
===========

My settings and scripts. The `install.sh` files should do the right thing when
provisioning a new machine. It requires connection for downloading things and
it assumes a distro where `apt` and `snap` are available (Ubuntu).

### Compile emacs

If you want to compile emacs you need to clone is first and then execute:

```
./configure --with-imagemagick --with-x-toolkit=gtk3 --with-xwidgets --enable-gtk-deprecation-warnings --with-xwidgets --with-x --with-wide-int  --with-gnutls=no --without-pop --prefix "/home/arichiardi/.local" --with-xwidgets --enable-gtk-deprecation-warnings --with-xwidgets --with-x --with-wide-int  --with-gnutls=no --without-pop --prefix "/path/to/user/home/.local"
make
make install
```
