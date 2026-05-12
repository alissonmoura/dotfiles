#!/usr/bin/env bash
set -euo pipefail

# Apply GNOME desktop environment settings for Ubuntu.
# Safe to re-run — all commands are idempotent.

log() {
  printf '[gnome-settings] %s\n' "$*"
}

warn() {
  printf '[gnome-settings][warn] %s\n' "$*" >&2
}

if ! command -v gsettings >/dev/null 2>&1; then
  warn "gsettings not found — not a GNOME desktop. Skipping."
  exit 0
fi

if [ -z "${XDG_CURRENT_DESKTOP:-}" ] || ! echo "$XDG_CURRENT_DESKTOP" | grep -qi gnome; then
  warn "Not running under GNOME desktop. Skipping."
  exit 0
fi

# ---------------------------------------------------------------------------
# Workspaces: 4 fixed, vertical layout
# ---------------------------------------------------------------------------
log "Configuring workspaces"
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

# ---------------------------------------------------------------------------
# Custom keybinding: Ctrl+Shift+T → Ghostty
# ---------------------------------------------------------------------------
log "Setting Ctrl+Shift+T → ghostty"
CUSTOM_KB_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
GHOSTTY_SLOT="${CUSTOM_KB_PATH}/custom0/"

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
  "['${GHOSTTY_SLOT}']"

dconf write "${GHOSTTY_SLOT}name" "'Launch Ghostty'"
dconf write "${GHOSTTY_SLOT}command" "'ghostty'"
dconf write "${GHOSTTY_SLOT}binding" "'<Control><Shift>t'"

# ---------------------------------------------------------------------------
# Dock / Dash-to-dock
# ---------------------------------------------------------------------------
log "Configuring dock"
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position "'LEFT'" 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 30 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.7 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action "'switch-workspace'" 2>/dev/null || true

# ---------------------------------------------------------------------------
# Power: prevent automatic sleep
# ---------------------------------------------------------------------------
log "Configuring power settings"
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'

# ---------------------------------------------------------------------------
# Keyboard & Input
# ---------------------------------------------------------------------------
log "Configuring input settings"
gsettings set org.gnome.desktop.peripherals.keyboard numlock-state true
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true

# ---------------------------------------------------------------------------
# Terminal 
# ---------------------------------------------------------------------------
gsettings set org.gnome.desktop.default-applications.terminal exec 'ghostty'   

log "GNOME settings applied"
