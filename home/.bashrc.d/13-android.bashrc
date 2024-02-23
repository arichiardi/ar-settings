if [ -d "$HOME/.local/share/android-platform-tools" ] ; then
 export PATH="$HOME/.local/share/android-platform-tools:$PATH"
fi

export ANDROID_HOME=/opt/android-sdk
alias activate-fdroid='source $HOME/.local/share/fdroid-env/bin/activate'
