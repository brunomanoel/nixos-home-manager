{ pkgs, ... }: {
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  environment.pathsToLink = [ "/share/zsh" ]; # https://mynixos.com/home-manager/option/programs.zsh.enableCompletion
}
