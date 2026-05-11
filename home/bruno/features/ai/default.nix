{
  lib,
  pkgs,
  ...
}:
let
  githubApp = import ../../../../lib/github-app.nix {
    inherit pkgs lib;
    privateKeyPath = "/run/secrets/predacoder-app-private-key";
    tokenCacheDir = "\${XDG_RUNTIME_DIR:-/tmp}/github-app-tokens";
  };
in
{
  _module.args.wrapWithAppIdentity = githubApp.wrapWithAppIdentity;

  imports = [
    ./mcp.nix
    ./claude-code.nix
    ./opencode.nix
    ./oh-my-openagent.nix
    ./rtk.nix
    ./pi.nix
  ];

  home.packages = [
    pkgs.openclaw
  ]
  # Ollama + Qdrant + Open WebUI disponíveis como CLI no Mac (serviços são NixOS-only)
  ++ lib.optionals pkgs.stdenv.isDarwin (
    with pkgs;
    [
      ollama
      qdrant
      open-webui
    ]
  );
}
