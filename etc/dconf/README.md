# How to configure gdm3

1. Create the /etc/dconf/profile/gdm which contains the following lines:

```
user-db:user
system-db:gdm
file-db:/usr/share/gdm/greeter-dconf-defaults
```

The `gdm` is the name of a dconf database and it is named `gdm-kap` in our case.

2. Create a gdm keyfile for machine-wide settings in `/etc/dconf/db/gdm-kap.d/01-gdm3-settings`:

```
[org/gnome/login-screen]
logo='/usr/share/icons/hicolor/256x256/apps/ubuntu-logo-icon.png'
fallback-logo='/usr/share/icons/hicolor/256x256/apps/ubuntu-logo-icon.png'

[org/gnome/login-screen]
disable-user-list=true
```

Note the `.d` suffix.

3. Update the system databases:

```
dconf update
```
