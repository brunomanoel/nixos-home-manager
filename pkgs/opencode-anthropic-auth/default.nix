{ stdenvNoCC, bun, nodejs, inputs, ... }:
let
  deps = stdenvNoCC.mkDerivation {
    pname = "opencode-anthropic-auth-deps";
    version = "1.5.1";
    src = inputs.opencode-anthropic-auth;
    nativeBuildInputs = [ bun ];
    buildPhase = ''
      bun install --frozen-lockfile --no-progress --ignore-scripts --no-cache
      rm -rf node_modules/.cache
    '';
    installPhase = ''
      mkdir -p $out
      cp -r node_modules $out/
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-NMGnNlcIjkVaegWUlaCf3+U1pcQP0idLCxbqzzi4gnM=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "opencode-anthropic-auth";
  version = "1.5.1";
  src = inputs.opencode-anthropic-auth;
  nativeBuildInputs = [ bun nodejs ];
  configurePhase = ''
    cp -r ${deps}/node_modules .
    chmod -R +w node_modules
    patchShebangs node_modules
  '';
  buildPhase = "bun run build";
  installPhase = ''
    mkdir -p $out
    cp -r dist package.json node_modules $out/
  '';
}
