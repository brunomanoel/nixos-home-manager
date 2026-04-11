{ inputs }:
{
  # Adds custom packages (Misterio77-style `additions` overlay).
  # For flake=false inputs (source-only), we pass them explicitly via callPackage.
  additions = final: _prev: {
    gsd = final.callPackage ../pkgs/gsd {
      gsd-src = inputs.gsd;
    };
  };
}
