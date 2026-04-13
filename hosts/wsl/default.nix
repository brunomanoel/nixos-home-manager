{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    # include NixOS-WSL modules
    inputs.nixos-wsl.nixosModules.default
    # VS Code server modules
    inputs.vscode-server.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ../common/global
    ../common/users/bruno
    ../common/optional/docker.nix
    ../common/optional/yubikey.nix
    # ../common/optional/ai-services.nix  # moved to cloudarm
  ];

  wsl.enable = true;
  wsl.defaultUser = "bruno";

  networking.hostName = "wsl";

  # --- Secrets (sops-nix) ---
  sops.secrets.wireguard-private-key.sopsFile = ./secrets.yaml;
  sops.secrets.github-mcp-token = {
    sopsFile = ./secrets.yaml;
    owner = "bruno";
  };

  # --- WireGuard to cloudarm ---
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.4/24" ];
    privateKeyFile = config.sops.secrets.wireguard-private-key.path;

    peers = [
      {
        # cloudarm
        publicKey = "pCMb0Db+WhhYqvDVqtAcat/ACxMt+FAWa1/Fmml6LlM=";
        allowedIPs = [ "10.100.0.0/24" ];
        endpoint = "137.131.233.96:51820";
        persistentKeepalive = 25;
      }
    ];
  };

  programs.nix-ld.enable = true;
  services.vscode-server.enable = true;
  services.vscode-server.enableFHS = true;
  services.vscode-server.extraRuntimeDependencies = [ pkgs.wget ];
  environment.systemPackages = [
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
