# Temporary override — nixpkgs has 0.35.0 which lacks `rtk hook claude`.
# Remove this package and the overlay entry once nixpkgs reaches >= 0.39.0.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "0.39.0";
  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-BuWCuhmW7wPnakQbmJarp53Rt0bOU50igpbGgbHFQBw=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-aarch64-unknown-linux-gnu.tar.gz";
      hash = "sha256-aP00y/9GhWgmoJLCYdZ7G4C1ee9sigQAwAieFDJecJ0=";
    };
  };
in
stdenv.mkDerivation {
  pname = "rtk";
  inherit version;
  src = sources.${stdenv.hostPlatform.system};
  sourceRoot = ".";
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isGnu [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isGnu [ stdenv.cc.cc.lib ];
  installPhase = ''
    install -Dm755 rtk $out/bin/rtk
  '';
  meta = {
    description = "CLI proxy that reduces LLM token consumption by 60-90%";
    homepage = "https://github.com/rtk-ai/rtk";
    license = lib.licenses.mit;
    platforms = builtins.attrNames sources;
    mainProgram = "rtk";
  };
}
