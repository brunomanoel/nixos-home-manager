{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  users.users.bruno = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ifTheyExist [
      "networkmanager"
      "wheel"
      "docker"
      "vboxusers"

      "audio"
      "git"
      "network"
      "podman"
      "video"
      "wireshark"
    ];

    openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
    packages = [pkgs.home-manager];
  };

  home-manager.users.bruno = import ../../../../home/bruno/${config.networking.hostName}.nix;
}
