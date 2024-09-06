# nixos-home-manager
My NixOS and Home Manager configuration

## Develop shell for bootstrapping
```shell
nix develop
# or
nix-shell
```

## Bootstrap

### Build system configuration

On the same directory
```shell
nh os switch . --ask
```
With `FLAKE` environment variable
```shell
FLAKE=/home/bruno/dotfiles nh os switch --ask
```

### Build user configuration

```shell
nh home switch --configuration=bruno@wsl .  --ask
```
