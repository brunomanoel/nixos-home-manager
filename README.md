# dotfiles

NixOS + nix-darwin + Home Manager — personal configuration

## Hosts

| Host        | Tipo                  | Sistema    | Perfil            |
|-------------|-----------------------|------------|-------------------|
| `wsl`       | WSL2 (Linux)          | NixOS      | `bruno@wsl`       |
| `predabook` | NixOS                 | NixOS      | `bruno@predabook` |
| `mac`       | macOS (Apple Silicon) | nix-darwin | `bruno@mac`       |

## Estrutura

```
home/bruno/features/
  cli/        # zsh, tmux, wezterm, starship, fzf...
  dev/        # neovim, vscode, ghidra, reverse-engineer

hosts/
  wsl/        # WSL2 host
  predabook/  # NixOS host
  mac/        # macOS (nix-darwin) host
  common/
    global/   # config compartilhada (+ darwin.nix / nix-darwin.nix para macOS)
    users/
    optional/
```

## Bootstrap (sistema novo)

Em um sistema sem as ferramentas instaladas, entre no dev shell primeiro:

```shell
nix develop
# ou
nix-shell
```

### NixOS / WSL

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

### Home Manager (standalone)

> Use apenas se quiser gerenciar o ambiente do usuário sem reconstruir o sistema
> (sem acesso a root, ou em sistemas onde apenas o HM está instalado).

```shell
nh home switch --configuration=bruno@wsl
nh home switch --configuration=bruno@predabook
nh home switch --configuration=bruno@mac
```
