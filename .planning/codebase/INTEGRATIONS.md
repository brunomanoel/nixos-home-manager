# External Integrations

**Analysis Date:** 2026-03-06

## Version Control & Code Hosting

**GitHub:**
- Used for: hosting this dotfiles repository and as git remote
- SSH auth: dedicated key `~/.ssh/github.key` (ed25519)
- SSH config: `home/bruno/features/cli/ssh.nix` → `matchBlocks."github.com"`
- Git signing: SSH signing with same key, always enabled: `home/bruno/features/git.nix`
- Git email: noreply address `26349861+brunomanoel@users.noreply.github.com`

## AI / Machine Learning

**Ollama (local LLM runtime):**
- Service: `services.ollama` (home-manager): `home/bruno/features/ollama.nix`
- Acceleration: CUDA (NVIDIA GPU on predabook)
- Models: commented out (`llama3.1:8b`, `deepseek-r1:1.5b` - not auto-loaded)
- Host: local only, no external API

**Open WebUI:**
- Service: `services.open-webui` enabled on WSL host: `hosts/wsl/default.nix`
- Access: `http://localhost:8080`
- Purpose: Browser-based chat interface for Ollama
- Scope: WSL host only

## Nix Binary Caches

**cache.nixos.org (default):**
- Implicit upstream Nix cache for all packages

**CUDA binary cache:**
- URL: `https://cache.nixos-cuda.org`
- Trusted key: `cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=`
- Config: `hosts/common/global/cuda.nix`
- Purpose: Pre-built CUDA derivations to avoid local compilation

## Remote Development

**VS Code Server (WSL):**
- Module: `inputs.vscode-server.nixosModules.default`: `hosts/wsl/default.nix`
- FHS compatibility: enabled (`enableFHS = true`)
- Extra runtime deps: `wget`
- Purpose: Enables `Remote - WSL` extension in VS Code running on Windows

## External Flake Inputs (GitHub)

All fetched from GitHub at pin in `flake.lock`:

| Input | Source |
|-------|--------|
| `nixpkgs` (unstable) | `github:NixOS/nixpkgs/nixos-unstable` |
| `nixpkgs-stable` | `github:nixos/nixpkgs/nixos-24.05` |
| `home-manager` | `github:nix-community/home-manager` |
| `nix-darwin` | `github:LnL7/nix-darwin` |
| `nixos-wsl` | `github:nix-community/NixOS-WSL/main` |
| `vscode-server` | `github:nix-community/nixos-vscode-server` |
| `nix-index-database` | `github:nix-community/nix-index-database` |
| `hardware` | `github:nixos/nixos-hardware` |
| `systems` | `github:nix-systems/default` |

## Authentication & Identity

**GPG Agent (Linux):**
- Implementation: `services.gpg-agent` with `enableSshSupport = true`
- Config: `home/bruno/features/cli/gpg.nix`
- SSH key pre-loaded: `~/.ssh/github.key` on login
- Passphrase cache: 24 hours

**macOS Keychain:**
- SSH keys persisted across reboots via `UseKeychain yes`
- Config: `home/bruno/features/cli/ssh.nix`

**Linux keychain (predabook):**
- `programs.keychain` pre-loads `github.key` at login
- Config: `home/bruno/features/cli/ssh.nix`

**GNOME Keyring:**
- Enabled on predabook for VS Code auth token storage
- Config: `hosts/common/optional/gnome.nix`

## Monitoring & Observability

**Error Tracking:** Not detected

**Logs:** systemd journal (standard NixOS/Linux logging)

## Desktop Integrations

**KDE Connect / GSConnect:**
- Predabook: `programs.kdeconnect.enable = true` (`hosts/predabook/default.nix`)
- GNOME: uses `gnomeExtensions.gsconnect` package (`hosts/common/optional/gnome.nix`)
- Purpose: Phone-desktop integration (clipboard, notifications, file transfer)

**GNOME Browser Connector:**
- `services.gnome.gnome-browser-connector.enable = true` (`hosts/common/optional/gnome.nix`)
- Purpose: Install GNOME extensions from browser

**EasyEffects:**
- `services.easyeffects.enable = true` (`home/bruno/features/utils.nix`)
- Purpose: PipeWire audio effects (noise reduction, EQ)
- Host: predabook only

## CI/CD & Deployment

**Hosting:** Local machines only — no cloud deployment
**CI Pipeline:** Not detected — no GitHub Actions, no CI config files found
**Rebuild method:** `nh` wrapper or `nixos-rebuild`/`darwin-rebuild`/`home-manager` CLI pointing at `$HOME/dotfiles`

## Communication & Productivity Apps

Installed via home-manager on predabook (`home/bruno/features/utils.nix`):
- **Discord** - Chat (`pkgs.discord`)
- **Spotify** - Music (`pkgs.spotify`)
- **Obsidian** - Notes (`pkgs.obsidian`)

## Webhooks & Callbacks

**Incoming:** Not applicable (personal workstation config, no web server)
**Outgoing:** Not applicable

## Secrets Location

- No secrets management system detected (no sops-nix, agenix, etc.)
- SSH private keys: `~/.ssh/github.key` (runtime, not committed)
- GPG keys: user GPG keyring (runtime, not committed)
- No `.env` files present in repo

---

*Integration audit: 2026-03-06*
