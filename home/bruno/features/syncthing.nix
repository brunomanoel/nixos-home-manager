{ pkgs, lib, ... }:
{
  services.syncthing = {
    enable = true;
    # Device IDs will be added as each machine is configured.
    # overrideDevices = true;
    # overrideFolders = true;
    # settings = {
    #   devices = {
    #     "predabook" = { id = "TODO"; };
    #     "laptop"    = { id = "TODO"; };
    #     "mac"       = { id = "TODO"; };
    #     "android"   = { id = "TODO"; };
    #   };
    #   folders = {
    #     "keepassxc" = {
    #       id = "keepassxc";
    #       path = "~/KeePassXC";
    #       devices = [ "predabook" "laptop" "mac" "android" ];
    #     };
    #   };
    # };
  };
}
