{ pkgs, ... }:

let
  # pi chama `npm install -g` para plugins de scope "user", o que tenta
  # escrever no nix store (read-only). Wrapper redireciona para dir gravável.
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
    ];
    npmCommand = [ "${piNpm}" ];
  };
}
