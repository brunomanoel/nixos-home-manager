{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extest.enable = true;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    gamescopeSession.enable = true;
  };

  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
      };
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
}
