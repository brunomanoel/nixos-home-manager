{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # include NixOS-WSL modules
    inputs.nixos-wsl.nixosModules.default
    ../common/global
    ../common/users/bruno
  ];

  wsl.enable = true;
  wsl.defaultUser = "bruno";

  networking.hostName = "wsl";

  environment.systemPackages = [
  	pkgs.micro
  	pkgs.fastfetch
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
