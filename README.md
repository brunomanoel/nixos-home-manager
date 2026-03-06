# dotfiles

NixOS + Home Manager — personal configuration

## Hosts

| Host        | Tipo         | Perfil              |
|-------------|--------------|---------------------|
| `wsl`       | WSL2 (Linux) | `bruno@wsl`         |
| `predabook` | NixOS        | `bruno@predabook`   |

## Estrutura

```
home/bruno/features/
  cli/        # zsh, tmux, wezterm, starship, fzf...
  dev/        # neovim, vscode, ghidra, reverse-engineer
```

## Bootstrap (sistema novo)

Em um sistema sem as ferramentas instaladas, entre no dev shell primeiro:

```shell
nix develop
# ou
nix-shell
```

Depois aplique a configuração do sistema e do usuário:

```shell
nh os switch . --ask
# ou com NH_FLAKE
NH_FLAKE=/home/bruno/dotfiles nh os switch --ask
```

```shell
nh home switch --configuration=bruno@wsl . --ask
# ou
nh home switch --configuration=bruno@predabook . --ask
```

## Aplicar mudanças

> `--ask` é opcional — faz dry run e pede confirmação antes de aplicar.

### Sistema (NixOS)
```shell
nh os switch
```

### Home Manager
```shell
nh home switch
```
