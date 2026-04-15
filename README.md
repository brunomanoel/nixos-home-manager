# dotfiles

NixOS + nix-darwin + Home Manager — personal configuration

## Hosts

| Host        | Type                           | System             | Profile           |
|-------------|--------------------------------|--------------------|-------------------|
| `predabook` | Desktop                        | NixOS unstable     | `bruno@predabook` |
| `cloudarm`  | Server (Oracle ARM A1.Flex)    | NixOS 25.11 stable | `bruno@cloudarm`  |
| `wsl`       | WSL2                           | NixOS unstable     | `bruno@wsl`       |
| `mac`       | macOS (Apple Silicon)          | nix-darwin         | `bruno@mac`       |

### Cloudarm — Oracle Cloud ARM (4 cores, 24GB RAM)

Self-hosted services hub. Accessed via WireGuard (`10.100.0.1`).

| Service | Access | Stack |
|---------|--------|-------|
| Pelican Panel | `http://pelican.local` / public IP port 80 | Nginx + PHP-FPM + SQLite |
| Pelican Wings | port 8080 | Go binary, manages Docker containers |
| CasaOS | `http://casaos.local` | Incus container (Debian 12), shared Docker |
| Nextcloud | `https://cloud.brunomanoel.ninja` / `nextcloud.local` | Nginx + PostgreSQL + PHP-FPM |
| ThingsBoard | `http://thingsboard.local` / `thingsboard.brunomanoel.ninja` | Docker container |
| Collabora Online | internal (consumed by Nextcloud) | Native NixOS service |
| Paperless-ngx | `http://paperless.local` | Native NixOS service |
| Playwright MCP | `http://10.100.0.1:8002/mcp` | Headless Chromium |

Uses `nixpkgs-stable` (25.11) with unstable overlay for Chromium (Playwright).

## Structure

```
home/bruno/
  features/
    ai/         # opencode, claude-code, MCP servers
    cli/        # zsh, starship, fzf, ssh...
    cli/wezterm.nix  # terminal (desktop only)
    dev/        # neovim, vscode, ghidra, reverse-engineer
  global/       # shared HM config (universal)
  global/fonts.nix  # fonts (desktop only)

hosts/
  predabook/    # Desktop NixOS
    secrets.yaml  # sops-nix (wireguard)
  cloudarm/     # Server NixOS (Oracle ARM)
    pelican.nix     # Pelican Panel + Wings
    casaos.nix      # CasaOS (Incus + provisioning)
    thingsboard.nix # ThingsBoard CE
    nextcloud.nix   # Nextcloud + Collabora + Paperless
    secrets.yaml    # sops-nix (wireguard, nextcloud, paperless)
  wsl/          # WSL2
    secrets.yaml  # sops-nix (wireguard)
  mac/          # macOS (nix-darwin)
  common/
    global/         # universal NixOS config (all hosts)
    global/sops.nix     # sops-nix + ed25519 host key
    global/desktop.nix  # desktop only (fonts, cuda, xkb, firmware)
    users/
    optional/
      openssh.nix     # hardened sshd (cloudarm only)
      gnome.nix       # GNOME + gpaste (desktop only)
      ai-services.nix # Ollama + Qdrant (desktop only)
```

## Bootstrap (new system)

Enter the dev shell (provides KeePassXC, sops, age, ssh-to-age):

```shell
nix develop
# or
nix-shell
```

1. Download `pessoal.kdbx` from Google Drive and open with KeePassXC
2. First `nixos-rebuild switch` generates the SSH ed25519 host key
3. Derive the age key and update `.sops.yaml`:
   ```shell
   ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
   ```
4. Create `hosts/<host>/secrets.yaml` with values from KeePassXC:
   ```shell
   sops hosts/<host>/secrets.yaml
   ```
5. Rebuild again to decrypt secrets via sops-nix

### NixOS / WSL (desktop)

Applies system and Home Manager together (HM is a NixOS module):

```shell
nh os switch . --ask
# or with NH_FLAKE
NH_FLAKE=/home/bruno/dotfiles nh os switch --ask
```

### macOS (nix-darwin)

Install Nix first (if not already installed):

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

First time, use `nix run` directly (before `nh` is available):

```shell
nix run nix-darwin -- switch --flake ~/dotfiles#mac
```

Subsequent times:

```shell
nh darwin switch --configuration mac ~/dotfiles
# or with NH_FLAKE
NH_FLAKE=~/dotfiles nh darwin switch --configuration mac
```

## Reinstallation

When reinstalling the OS on a host that already had sops-nix configured:

1. SSH host key changes — derive the new age key with `ssh-to-age`
2. Update `.sops.yaml` with the new key
3. Re-encrypt the host's secrets for the new key:
   ```shell
   sops updatekeys hosts/<host>/secrets.yaml
   ```
4. Commit, push and rebuild

## Applying changes

> `--ask` is optional — performs a dry run and asks for confirmation before applying.

### NixOS / WSL
```shell
nh os switch
```

### macOS (nix-darwin)
```shell
nh darwin switch --configuration mac
```

### Cloudarm (remote server)

```shell
ssh root@cloudarm
cd /root/dotfiles && git pull && nixos-rebuild switch --flake .#cloudarm
```

### Home Manager (standalone)

> Use only if you want to manage the user environment without rebuilding the system
> (no root access, or on systems where only HM is installed).

```shell
nh home switch --configuration=bruno@wsl
nh home switch --configuration=bruno@predabook
nh home switch --configuration=bruno@mac
```
