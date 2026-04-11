{ stdenv, pnpm_10, pnpmConfigHook, nodejs_22, fetchPnpmDeps, inputs, ... }:
stdenv.mkDerivation (finalAttrs: {
  pname = "local-rag";
  version = (builtins.fromJSON (builtins.readFile "${inputs.local-rag}/package.json")).version;
  src = inputs.local-rag;

  nativeBuildInputs = [ pnpm_10 pnpmConfigHook nodejs_22 ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-y+gFXoonTK0UdOUsK6VLJ8A3huabP92NyjGhFpfC6Uo=";
  };

  buildPhase = ''
    export HOME=$TMPDIR
    export NG_CLI_ANALYTICS=false
    pnpm build
    substituteInPlace dist/tools/recall.js \
      --replace-fail 'content.slice(0, 200)' 'content'
  '';

  dontFixup = true;

  installPhase = ''
    mkdir -p $out
    cp -r dist node_modules package.json $out/
  '';
})
