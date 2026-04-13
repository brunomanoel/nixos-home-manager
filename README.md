# dotfiles

NixOS + nix-darwin + Home Manager — personal configuration

## Hosts

| Host        | Tipo                           | Sistema            | Perfil            |
|-------------|--------------------------------|--------------------|-------------------|
| `predabook` | Desktop                        | NixOS unstable     | `bruno@predabook` |
| `cloudarm`  | Server (Oracle ARM A1.Flex)     | NixOS 25.11 stable | `bruno@cloudarm`  |
| `wsl`       | WSL2                           | NixOS unstable     | `bruno@wsl`       |
| `mac`       | macOS (Apple Silicon)          | nix-darwin         | `bruno@mac`       |

### Cloudarm — Oracle Cloud ARM (4 cores, 24GB RAM)

Game server + self-hosted services. Acesso via WireGuard (`10.100.0.1`).

| Serviço | Acesso | Stack |
|---------|--------|-------|
| Pelican Panel | `http://pelican.local` / IP público porta 80 | Caddy + PHP-FPM + SQLite |
| Pelican Wings | porta 8080 | binário Go, gerencia Docker containers |
| CasaOS | `http://casaos.local` | Incus container (Debian 12), Docker compartilhado |
| Playwright MCP | `http://10.100.0.1:8002/mcp` | Chromium headless |

Usa `nixpkgs-stable` (25.11) com overlay unstable para chromium (Playwright).

## Estrutura

```
home/bruno/
  features/
    ai/         # opencode, claude-code, MCP servers
    cli/        # zsh, starship, fzf, ssh...
    cli/wezterm.nix  # terminal (desktop only)
    dev/        # neovim, vscode, ghidra, reverse-engineer
  global/       # config HM compartilhada (universal)
  global/fonts.nix  # fontes (desktop only)

hosts/
  predabook/    # Desktop NixOS
    secrets.yaml  # sops-nix (wireguard, github-mcp-token)
  cloudarm/     # Server NixOS (Oracle ARM)
    pelican.nix   # Pelican Panel + Wings + Caddy
    secrets.yaml  # sops-nix (wireguard)
  wsl/          # WSL2
    secrets.yaml  # sops-nix (wireguard, github-mcp-token)
  mac/          # macOS (nix-darwin)
  common/
    global/         # config NixOS universal (todos os hosts)
    global/sops.nix     # sops-nix + host key ed25519
    global/desktop.nix  # só desktops (fonts, cuda, xkb, firmware)
    users/
    optional/
      openssh.nix     # sshd com hardening (só cloudarm)
      ai-services.nix # Ollama + Qdrant (desktop only)
```

## Bootstrap (sistema novo)

Entre no dev shell (traz KeePassXC, sops, age, ssh-to-age):

```shell
nix develop
# ou
nix-shell
```

1. Baixar `pessoal.kdbx` do Google Drive e abrir com KeePassXC
2. O primeiro `nixos-rebuild switch` gera a SSH host key ed25519
3. Derivar a age key e atualizar `.sops.yaml`:
   ```shell
   ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
   ```
4. Criar `hosts/<host>/secrets.yaml` com os valores do KeePassXC:
   ```shell
   sops hosts/<host>/secrets.yaml
   ```
5. Rebuild novamente para decriptar os secrets via sops-nix

### NixOS / WSL (desktop)

Aplica o sistema e o Home Manager juntos (HM é um módulo NixOS):

```shell
nh os switch . --ask
# ou com NH_FLAKE
NH_FLAKE=/home/bruno/dotfiles nh os switch --ask
```

### macOS (nix-darwin)

Instale o Nix primeiro (caso ainda não esteja instalado):

```shell
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Na primeira vez, use `nix run` diretamente (antes de `nh` estar disponível):

```shell
nix run nix-darwin -- switch --flake ~/dotfiles#mac
```

Nas próximas vezes:

```shell
nh darwin switch --configuration mac ~/dotfiles
# ou com NH_FLAKE
NH_FLAKE=~/dotfiles nh darwin switch --configuration mac
```

## Reinstalação

Ao reinstalar o OS num host que já tinha sops-nix configurado:

1. A SSH host key muda — derivar a nova age key com `ssh-to-age`
2. Atualizar `.sops.yaml` com a nova key
3. Re-encriptar os secrets do host para a nova key:
   ```shell
   sops updatekeys hosts/<host>/secrets.yaml
   ```
4. Commit, push e rebuild

## Aplicar mudanças

> `--ask` é opcional — faz dry run e pede confirmação antes de aplicar.

### NixOS / WSL
```shell
nh os switch
```

### macOS (nix-darwin)
```shell
nh darwin switch --configuration mac
```

### Cloudarm (server remoto)

```shell
ssh root@cloudarm
cd /root/dotfiles && git pull && nixos-rebuild switch --flake .#cloudarm
```

### Home Manager (standalone)

> Use apenas se quiser gerenciar o ambiente do usuário sem reconstruir o sistema
> (sem acesso a root, ou em sistemas onde apenas o HM está instalado).

```shell
nh home switch --configuration=bruno@wsl
nh home switch --configuration=bruno@predabook
nh home switch --configuration=bruno@mac
```
