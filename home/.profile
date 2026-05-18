_ar_helpers="$HOME/.local/share/ar/helpers.sh"
if [ -r "$_ar_helpers" ]; then
    source "$_ar_helpers"
fi

for f in "${HOME}/.profile.d"/[0-9][0-9]-*.bash; do
  if [ -r "$f" ]; then
    if declare -f source_with_bench >/dev/null 2>&1; then
      source_with_bench "$f"
    else
      source "$f"
    fi
  fi
done
