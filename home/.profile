source "$HOME/.local/share/ar/helpers.sh"

for f in "${HOME}/.profile.d"/[0-9][0-9]-*.bash; do
  if [ -r "$f" ]; then
    source_with_bench "$f"
  fi
done
