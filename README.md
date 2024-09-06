# nixos-home-manager
My NixOS and Home Manager configuration

## Develop shell for bootstrapping
```shell
nix develop
# or
nix-shell
```

## Bootstrap

To build system configuration

```shell
nh os switch . --ask
```

To build user configuration

```shell
nh home switch . --ask
```
