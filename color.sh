#!/usr/bin/env sh

background="$1"

case "$background" in
   light)
      theme="Catppuccin Latte"
      ;;
   dark|"")
      theme="Catppuccin Macchiato"
      ;;
   *)
      echo "Usage: color.sh [dark|light]"
      exit 1
      ;;
esac

ghostty_config="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
mkdir -p "$(dirname "$ghostty_config")"

if [ -f "$ghostty_config" ] && grep -q '^theme = ' "$ghostty_config"; then
   sed -i "s/^theme = .*/theme = $theme/" "$ghostty_config"
else
   {
      [ -f "$ghostty_config" ] && cat "$ghostty_config"
      echo "theme = $theme"
   } > "${ghostty_config}.tmp"
   mv "${ghostty_config}.tmp" "$ghostty_config"
fi

# Reload config if Ghostty is currently running.
if command -v ghostty >/dev/null 2>&1; then
   ghostty +reload-config >/dev/null 2>&1 || true
fi

echo "Ghostty theme set to $theme"


