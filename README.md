# dotfiles

Dotfiles for a Linux workstation with:

- Oh My Zsh + Catppuccin prompt
- Neovim + Catppuccin
- tmux + Catppuccin (via TPM)
- Ghostty + Catppuccin
- git and utility shell scripts

## Quick Start On A New Computer

1. Clone this repository.
2. Run the bootstrap script:

```bash
bash ./scripts/bootstrap.sh
```

The script will:

- install base packages (`git`, `curl`, `zsh`, `tmux`, `neovim`, `xclip`)
- attempt to install `ghostty` (and warn if unavailable in your distro repos)
- install Oh My Zsh
- install TPM (tmux plugin manager)
- symlink dotfiles to your home config paths
- install tmux plugins and sync Neovim plugins
- set zsh as default shell

Existing files in your home directory are backed up under:

```text
~/.dotfiles-backup/<timestamp>
```

## Theme Notes

- Neovim stays on Catppuccin (macchiato)
- tmux uses Catppuccin plugin flavor macchiato
- Ghostty uses Catppuccin Macchiato
- zsh uses local theme `catppuccin_macchiato`

## Optional Theme Toggle

`color.sh` can switch Ghostty between dark and light Catppuccin flavors:

```bash
color.sh dark
color.sh light
```

