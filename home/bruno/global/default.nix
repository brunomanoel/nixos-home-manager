{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    ../features/ai
  ];

  nix = {
    package = lib.mkDefault pkgs.nix;
    # experimental-features set at system level (nix.nix / nix-darwin.nix)
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      allowInsecurePredicate = pkg: pkg.pname == "openclaw";
    };
  };

  systemd.user.startServices = lib.mkIf pkgs.stdenv.isLinux "sd-switch";

  programs = {
    home-manager.enable = true;
    git.enable = true;
    nix-index-database.comma.enable = true;
  };

  home = {
    username = lib.mkDefault "bruno";
    homeDirectory = lib.mkDefault (
      if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}"
    );
    stateVersion = lib.mkDefault "23.05";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      NH_FLAKE = "$HOME/dotfiles";
      # BROWSER = "firefox";
      # TERMINAL = "alacritty";
    };
  };
}
