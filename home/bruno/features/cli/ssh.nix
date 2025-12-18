{ config, pkgs, lib, ... }:
{
  programs.ssh = {
    enable = true;
    forwardAgent = true;
  };
}
