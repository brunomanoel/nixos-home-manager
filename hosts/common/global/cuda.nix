{
  nix.settings = {
    # Use `extra-*` to APPEND to the default substituters/keys instead of
    # replacing them. Plain `substituters`/`trusted-public-keys` overrides the
    # defaults, which would drop cache.nixos.org and force everything to
    # compile from source.
    extra-substituters = [
      "https://cache.nixos-cuda.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };
}
