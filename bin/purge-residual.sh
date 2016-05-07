#!/bin/bash

# https://askubuntu.com/questions/376253/is-not-installed-residual-config-safe-to-remove-all
dpkg -l | grep '^rc' | awk '{print $2}' | sudo xargs dpkg --purge
