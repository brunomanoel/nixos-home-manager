{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./mcp.nix
    ./claude-code.nix
    ./opencode.nix
    ./oh-my-openagent.nix
  ];

  # Ollama + Qdrant + Open WebUI disponíveis como CLI no Mac (serviços são NixOS-only)
  home.packages = [
    pkgs.openclaw
  ]
  ++ lib.optionals pkgs.stdenv.isDarwin (
    with pkgs;
    [
      ollama
      qdrant
      open-webui
    ]
  );
}
