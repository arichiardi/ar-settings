_ar_helpers="$HOME/.local/share/ar/helpers.sh"
if [ -r "$_ar_helpers" ]; then
    source "$_ar_helpers"
fi

for f in "${HOME}/.profile.d"/[0-9][0-9]-*.bash; do
  if [ -r "$f" ]; then
    source_with_bench "$f"
  fi
done
