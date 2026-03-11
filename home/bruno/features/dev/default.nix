{ pkgs, ... } : {
  imports = [
    ./vscode.nix
    ./neovim
    ./reverse-engineer.nix
  ];

  home.packages = with pkgs; [
    opencode
    claude-code
  ];
}
