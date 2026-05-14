{ pkgs, ... }:

let
  # pi calls `npm install -g` for user-scoped plugins, which tries to write
  # to the nix store (read-only). Wrapper redirects to a writable directory.
  piNpm = pkgs.writeShellScript "pi-npm" ''
    export NPM_CONFIG_PREFIX="$HOME/.local/share/pi/npm"
    exec ${pkgs.nodejs}/bin/npm "$@"
  '';
in
{
  home.packages = [ pkgs.pi-coding-agent ];

  home.file.".pi/agent/settings.json".text = builtins.toJSON {
    packages = [
      "npm:pi-anthropic-oauth"
      "npm:pi-mcp-adapter"
    ];
    npmCommand = [ "${piNpm}" ];
    enabledModels = [
      "claude-sonnet-4-6"
      "claude-opus-4-6"
      "gpt-5.4"
    ];
  };
}
