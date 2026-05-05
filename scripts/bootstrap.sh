#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
PKG_MANAGER=""
TARGET_OS="auto"

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--os auto|linux|macos] [--help]

Options:
  --os      Target OS behavior. Defaults to auto.
  --help    Show this help.
EOF
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --os)
        if [ "$#" -lt 2 ]; then
          warn "Missing value for --os"
          usage
          exit 1
        fi
        TARGET_OS="$2"
        shift 2
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        warn "Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  case "$TARGET_OS" in
    auto|linux|macos)
      ;;
    *)
      warn "Invalid --os value: $TARGET_OS (expected: auto|linux|macos)"
      exit 1
      ;;
  esac
}

log() {
  printf '[dotfiles] %s\n' "$*"
}

warn() {
  printf '[dotfiles][warn] %s\n' "$*" >&2
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

detect_pkg_manager() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  elif command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  elif command -v zypper >/dev/null 2>&1; then
    echo "zypper"
  else
    echo "none"
  fi
}

install_apt_packages_if_available() {
  local available_packages=()
  local package

  for package in "$@"; do
    if apt-cache show "$package" >/dev/null 2>&1; then
      available_packages+=("$package")
    else
      warn "apt package not found: $package"
    fi
  done

  if [ "${#available_packages[@]}" -gt 0 ]; then
    run_as_root apt-get install -y "${available_packages[@]}"
  fi
}

configure_brave_apt_repository() {
  local arch
  local distro_id
  distro_id="$(
    . /etc/os-release
    echo "${ID:-}"
  )"

  if [ "$distro_id" != "ubuntu" ]; then
    warn "Brave apt repository setup is only configured for Ubuntu. Skipping."
    return
  fi

  arch="$(dpkg --print-architecture)"

  run_as_root install -m 0755 -d /etc/apt/keyrings
  run_as_root curl -fsSL \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
    -o /etc/apt/keyrings/brave-browser-archive-keyring.gpg
  printf 'deb [signed-by=/etc/apt/keyrings/brave-browser-archive-keyring.gpg arch=%s] https://brave-browser-apt-release.s3.brave.com/ stable main\n' \
    "$arch" | run_as_root tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null
}

configure_docker_apt_repository() {
  local arch
  local codename
  local distro_id
  distro_id="$(
    . /etc/os-release
    echo "${ID:-}"
  )"

  if [ "$distro_id" != "ubuntu" ]; then
    warn "Docker apt repository setup is only configured for Ubuntu. Skipping."
    return
  fi

  arch="$(dpkg --print-architecture)"
  codename="$(
    . /etc/os-release
    echo "${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
  )"

  if [ -z "$codename" ]; then
    warn "Could not determine Ubuntu codename. Docker repository setup skipped."
    return
  fi

  run_as_root install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | run_as_root gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  run_as_root chmod a+r /etc/apt/keyrings/docker.gpg
  printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu %s stable\n' \
    "$arch" "$codename" | run_as_root tee /etc/apt/sources.list.d/docker.list >/dev/null
}

install_snap_packages() {
  local package

  if ! command -v snap >/dev/null 2>&1; then
    warn "snap command not found. Skipping ghostty/go/nvim snap installation."
    return
  fi

  for package in ghostty go nvim; do
    if snap list "$package" >/dev/null 2>&1; then
      log "Snap package already installed: $package"
      continue
    fi

    if ! run_as_root snap install "$package" --classic; then
      warn "Failed to install snap package: $package"
    fi
  done
}

install_packages() {
  case "$PKG_MANAGER" in
    apt)
      run_as_root apt-get update
      run_as_root apt-get install -y ca-certificates curl gnupg
      configure_brave_apt_repository
      configure_docker_apt_repository
      run_as_root apt-get update
      install_apt_packages_if_available \
        git curl zsh tmux xclip \
        apt-transport-https ca-certificates wget gnupg gpg unzip \
        build-essential fontconfig \
        python3-pip python3-venv python3.12-venv python3-isort \
        tree-sitter-cli chromium-browser brave-browser \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      install_snap_packages
      ;;
    dnf)
      run_as_root dnf install -y git curl zsh tmux neovim xclip
      if dnf list --quiet ghostty >/dev/null 2>&1; then
        run_as_root dnf install -y ghostty
      else
        warn "ghostty package not found in dnf repositories. Install it manually from https://ghostty.org/docs/install/"
      fi
      ;;
    pacman)
      run_as_root pacman -Syu --needed --noconfirm git curl zsh tmux neovim xclip
      if pacman -Si ghostty >/dev/null 2>&1; then
        run_as_root pacman -S --needed --noconfirm ghostty
      else
        warn "ghostty package not found in pacman repositories. Install it manually from https://ghostty.org/docs/install/"
      fi
      ;;
    zypper)
      run_as_root zypper --non-interactive refresh
      run_as_root zypper --non-interactive install git curl zsh tmux neovim xclip
      if ! run_as_root zypper --non-interactive install ghostty; then
        warn "ghostty package not found in zypper repositories. Install it manually from https://ghostty.org/docs/install/"
      fi
      ;;
    *)
      warn "No supported package manager found. Install git, curl, zsh, tmux, neovim, xclip, and ghostty manually."
      ;;
  esac
}

backup_target() {
  local target="$1"
  local relative
  local backup_target_path

  relative="${target#"$HOME"/}"
  if [ "$relative" = "$target" ]; then
    relative="$(basename "$target")"
  fi

  backup_target_path="$BACKUP_DIR/$relative"
  mkdir -p "$(dirname "$backup_target_path")"
  mv "$target" "$backup_target_path"
  log "Backed up $target to $backup_target_path"
}

link_item() {
  local source="$1"
  local target="$2"
  local linked_target

  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ]; then
    linked_target="$(readlink "$target" || true)"
    if [ "$linked_target" = "$source" ]; then
      log "Already linked: $target"
      return
    fi
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    backup_target "$target"
  fi

  ln -s "$source" "$target"
  log "Linked $target -> $source"
}

install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing Oh My Zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    log "Oh My Zsh is already installed"
  fi
}

install_tpm() {
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    log "Installing tmux plugin manager"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    log "tmux plugin manager is already installed"
  fi
}

link_dotfiles() {
  link_item "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
  link_item "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"
  link_item "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
  link_item "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  link_item "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"
  link_item "$DOTFILES_DIR/color.sh" "$HOME/.local/bin/color.sh"

  mkdir -p "$HOME/.oh-my-zsh/custom/themes"
  link_item \
    "$DOTFILES_DIR/zsh/themes/catppuccin_macchiato.zsh-theme" \
    "$HOME/.oh-my-zsh/custom/themes/catppuccin_macchiato.zsh-theme"

  chmod +x "$HOME/.local/bin/color.sh"
}

install_tmux_plugins() {
  if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    log "Installing tmux plugins"
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "Failed to install tmux plugins automatically"
  fi
}

install_nvim_plugins() {
  local nvim_bin=""

  if command -v nvim >/dev/null 2>&1; then
    nvim_bin="$(command -v nvim)"
  elif [ -x /snap/bin/nvim ]; then
    nvim_bin="/snap/bin/nvim"
  fi

  if [ -n "$nvim_bin" ]; then
    log "Syncing Neovim plugins"
    "$nvim_bin" --headless "+Lazy! sync" +qa || warn "Failed to sync Neovim plugins automatically"
  else
    warn "Neovim not found in PATH. Plugin sync skipped."
  fi
}

set_default_shell() {
  local current_shell
  local desired_shell

  if ! command -v zsh >/dev/null 2>&1; then
    warn "zsh is not available, default shell not changed"
    return
  fi

  desired_shell="$(command -v zsh)"

  if command -v getent >/dev/null 2>&1; then
    current_shell="$(getent passwd "$USER" | cut -d: -f7 || true)"
  elif [ "$(uname -s)" = "Darwin" ] && command -v dscl >/dev/null 2>&1; then
    current_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}' || true)"
  else
    current_shell="${SHELL:-}"
  fi

  if [ "$current_shell" != "$desired_shell" ]; then
    if command -v chsh >/dev/null 2>&1; then
      log "Changing default shell to $desired_shell"
      if ! chsh -s "$desired_shell"; then
        warn "Could not change default shell automatically. Run: chsh -s $desired_shell"
      fi
    else
      warn "chsh not available. Run manually: chsh -s $desired_shell"
    fi
  fi
}

main() {
  log "Starting bootstrap from $DOTFILES_DIR"
  mkdir -p "$BACKUP_DIR"

  parse_args "$@"

  local effective_os
  if [ "$TARGET_OS" = "auto" ]; then
    case "$(uname -s)" in
      Darwin)
        effective_os="macos"
        ;;
      *)
        effective_os="linux"
        ;;
    esac
  else
    effective_os="$TARGET_OS"
  fi

  log "Using OS profile: $effective_os"

  PKG_MANAGER="$(detect_pkg_manager)"
  log "Detected package manager: $PKG_MANAGER"

  if [ "$effective_os" = "linux" ]; then
    install_packages
  else
    log "Skipping Linux package installation for macOS profile"
  fi
  install_oh_my_zsh
  install_tpm
  link_dotfiles
  install_tmux_plugins
  install_nvim_plugins
  set_default_shell

  # Apply GNOME desktop settings (skips gracefully on non-GNOME)
  if [ "$effective_os" = "linux" ] && [ -x "$DOTFILES_DIR/scripts/gnome-settings.sh" ]; then
    log "Applying GNOME settings"
    "$DOTFILES_DIR/scripts/gnome-settings.sh"
  fi

  log "Bootstrap complete"
  log "Restart your shell session or run: exec zsh"
}

main "$@"
