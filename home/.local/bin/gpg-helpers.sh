#!/usr/bin/env bash

gpg_s2k_args="--s2k-mode 3 --s2k-digest-algo SHA256 --s2k-cipher-algo AES256 --s2k-count 65011712"

gpg_symmetric_args="--cipher-algo aes256 \
  --digest-algo sha256 \
  --cert-digest-algo sha256 \
  --compress-algo none -z 0 \
  --force-mdc \
  --no-greeting \
  --pinentry-mode=loopback \
  $gpg_s2k_args"
