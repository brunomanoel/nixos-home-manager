{ inputs }:
{
  # Exposes flake inputs as `pkgs.inputs` so callPackage can auto-wire them
  # into pkg files that declare `inputs` in their arg set.
  flake-inputs = _final: _prev: {
    inherit inputs;
  };

  # Adds custom packages (Misterio77-style `additions` overlay).
  additions = final: _prev: {
    gsd = final.callPackage ../pkgs/gsd {
      gsd-src = inputs.gsd;
    };
    opencode-anthropic-auth = final.callPackage ../pkgs/opencode-anthropic-auth { };
    local-rag = final.callPackage ../pkgs/local-rag { };
  };
}
