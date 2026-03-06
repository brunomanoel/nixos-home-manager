# Technology Stack

**Analysis Date:** 2026-03-06

## Languages

**Primary:**
- Nix (DSL) - All configuration files: `flake.nix`, `shell.nix`, `hosts/**/*.nix`, `home/**/*.nix`
- Lua - Neovim configuration: `home/bruno/features/dev/neovim/init.lua`

**Secondary:**
- Bash/Zsh shell scripting - Inline scripts in home-manager modules (e.g., `home/bruno/features/cli/gpg.nix` profileExtra/loginExtra)

## Runtime

**Environment:**
- Nix package manager - manages all software declaratively via `flake.nix`
- Supported platforms: `x86_64-linux` (NixOS, WSL), `aarch64-darwin` (macOS)

**Package Manager:**
- Nix with Flakes (experimental features: `nix-command`, `flakes`, `ca-derivations`)
- Lockfile: `flake.lock` - present and committed

## Frameworks

**Core:**
- NixOS - Linux OS configuration framework, entry point `flake.nix` → `nixosConfigurations`
- nix-darwin - macOS system configuration framework, entry point `flake.nix` → `darwinConfigurations`
- home-manager - User environment configuration, entry point `flake.nix` → `homeConfigurations`

**Build/Dev:**
- `nh` (Nice Home manager/NixOS wrapper) - CLI convenience wrapper for rebuilds
- `nix-output-monitor` (nom) - Enhanced build output display
- `nvd` - NixOS/nix version diff tool for comparing generations
- `nix-diff` - Detailed derivation differ
- `alejandra` + `nixfmt` - Nix code formatters
- `nixd` - Nix language server (LSP) for editor support
- `direnv` + `nix-direnv` - Per-project environment loading: `home/bruno/features/cli/default.nix`

## Key Dependencies (Flake Inputs)

**Critical:**
- `nixpkgs` (nixos-unstable) - Primary package set for all hosts: `github:NixOS/nixpkgs/nixos-unstable`
- `nixpkgs-stable` (nixos-24.05) - Stable channel as fallback: `github:nixos/nixpkgs/nixos-24.05`
- `home-manager` - User environment management: `github:nix-community/home-manager`
- `nix-darwin` - macOS system management: `github:LnL7/nix-darwin`

**Infrastructure:**
- `nixos-wsl` - WSL2 NixOS integration: `github:nix-community/NixOS-WSL/main`
- `vscode-server` - VS Code remote server on WSL: `github:nix-community/nixos-vscode-server`
- `nix-index-database` - `comma` and `command-not-found` backend: `github:nix-community/nix-index-database`
- `hardware` (nixos-hardware) - Hardware-specific NixOS modules: `github:nixos/nixos-hardware`
- `systems` - Multi-system helper: `github:nix-systems/default`

## Host Configurations

**predabook** (`hosts/predabook/`) - NixOS on Lenovo Legion laptop:
- CPU: Intel + NVIDIA GPU (CUDA enabled)
- Boot: GRUB (EFI + OS prober dual-boot)
- DE: GNOME on Wayland (GDM)
- Extras: Docker, VirtualBox, gaming, KDE Connect, PipeWire

**wsl** (`hosts/wsl/`) - NixOS inside Windows Subsystem for Linux:
- NixOS-WSL module
- VS Code Server (with FHS compatibility)
- Docker
- `open-webui` served at `http://localhost:8080` (Ollama web portal)

**mac** (`hosts/mac/`) - macOS on Apple Silicon (aarch64-darwin):
- nix-darwin
- Touch ID for sudo
- Timezone: America/Sao_Paulo

## Shell Environment

**Default Shell:** Zsh (set system-wide in `hosts/common/global/zsh.nix`)

**Key CLI Programs (via home-manager):**
- `starship` - Cross-shell prompt: `home/bruno/features/cli/starship.nix`
- `tmux` - Terminal multiplexer: `home/bruno/features/cli/tmux.nix`
- `fzf` - Fuzzy finder: `home/bruno/features/cli/fzf.nix`
- `wezterm` - Terminal emulator (FiraCode Nerd Font, Catppuccin Mocha, 80% opacity): `home/bruno/features/cli/default.nix`
- `bat` (cat replacement, Dracula theme)
- `eza` (ls replacement with icons/git integration)
- `zoxide` (cd replacement)
- `ripgrep`, `jq`, `btop`, `htop`, `bottom`, `ncdu`
- `navi` - Interactive command cheatsheet

**Zsh Plugins:**
- `zsh-nix-shell` - Nix shell integration
- `zsh-you-should-use` - Alias reminders
- `zsh-forgit` - Interactive git with fzf
- `zsh-fzf-tab` - fzf-powered tab completion
- `zsh-autopair` - Auto bracket/quote pairing

## Editor

**Primary:** Neovim (`home/bruno/features/dev/neovim/`)
- Config: Lua (`init.lua`)
- Plugins: treesitter, telescope, nvim-tree, lualine, which-key, vim-tmux-navigator
- Theme: Dracula / Catppuccin

**Secondary:** VS Code (`home/bruno/features/dev/vscode.nix`)
- Update checks disabled, mutable extensions dir

## Security

**GPG:** `home/bruno/features/cli/gpg.nix`
- `gpg-agent` with SSH support enabled
- SSH key cached for 24h (`defaultCacheTtlSsh = 86400`)
- Pinentry: gtk2 (if GTK available) or tty

**SSH:** `home/bruno/features/cli/ssh.nix`
- Linux: `keychain` pre-loads `~/.ssh/github.key` at login
- macOS: `UseKeychain yes` delegates to system Keychain
- Agent forwarding enabled globally

**Git Signing:** SSH signing (ed25519 key), enabled by default (`home/bruno/features/git.nix`)

## Nix Store Management

- Auto-optimize: enabled (Linux only)
- GC: automatic weekly, keeps last 3 generations (`--delete-older-than +3`)
- Binary cache: `https://cache.nixos-cuda.org` added for CUDA packages

## Configuration

**Environment Variables:**
- `NH_FLAKE = "$HOME/dotfiles"` - Points `nh` at the flake
- `NIXOS_OZONE_WL = "1"` - Enables Wayland for Electron apps (predabook)

**Build:**
- `shell.nix` provides a development shell with `nix`, `home-manager`, `git`, `nh`, `nvd`, `nix-output-monitor`

## Platform Requirements

**Development:**
- Nix with flakes support
- Git (for flake inputs)

**Production:**
- NixOS (predabook, wsl) or macOS with nix-darwin (mac)
- NVIDIA drivers + CUDA required on predabook for Ollama CUDA acceleration

---

*Stack analysis: 2026-03-06*
