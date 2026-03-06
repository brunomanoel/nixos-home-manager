{
  inputs,
  pkgs,
  config,
  ...
}: {
  users.users.bruno = {
    home = "/Users/bruno";
    shell = pkgs.zsh;
  };

  home-manager.users.bruno = import ../../../../home/bruno/${config.networking.hostName}.nix;
}
