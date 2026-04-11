{ lib, runCommand, nodejs_22, gsd-src }:

let
  version = (builtins.fromJSON (builtins.readFile "${gsd-src}/package.json")).version;
in
runCommand "gsd-${version}"
  {
    inherit version;
    src = gsd-src;
    passthru = { inherit version; };
    nativeBuildInputs = [ nodejs_22 ];
    meta = with lib; {
      description = "GSD (Get Shit Done) runtime for Claude Code and OpenCode";
      homepage = "https://github.com/gsd-build/get-shit-done";
      license = licenses.mit;
      platforms = platforms.all;
    };
  }
  ''
    # The installer writes into cwd during setup; work from a mutable copy.
    cp -r $src ./gsd-src
    chmod -R u+w ./gsd-src
    cd ./gsd-src

    mkdir -p $out/share/claude-code $out/share/opencode

    # Non-interactive install via flags. --config-dir makes the installer
    # write to the given path instead of $HOME/.claude (or $HOME/.config/opencode),
    # so we never need to mock $HOME or run against a live config directory.
    node bin/install.js --claude   --global --config-dir $out/share/claude-code
    node bin/install.js --opencode --global --config-dir $out/share/opencode

    # Home-manager redeclares settings.json fully; the installer-generated copy
    # bakes in absolute paths from the sandbox and is not portable. The manifest
    # is only useful to the installer itself.
    rm -f $out/share/claude-code/settings.json
    rm -f $out/share/claude-code/gsd-file-manifest.json
    rm -f $out/share/claude-code/package.json
    rm -f $out/share/opencode/settings.json
    rm -f $out/share/opencode/gsd-file-manifest.json
    rm -f $out/share/opencode/opencode.json
    rm -f $out/share/opencode/package.json
  ''
