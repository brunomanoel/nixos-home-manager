{ ... }:
{
  imports = [
    ./vscode.nix
    ./neovim
    ./reverse-engineer.nix
  ];
  # claude-code e opencode gerenciados por programs.claude-code e programs.opencode em claude.nix
}
