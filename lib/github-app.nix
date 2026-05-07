# PrêdaCoder[bot] GitHub App identity — shared builder.
#
# Returns { gitAskpassScript, ghAppToken, wrapWithAppIdentity } parameterized
# by private key path and token cache location.
#
# Consumers:
#   - hosts/cloudarm/paperclip.nix   (NixOS service)
#   - home/bruno/features/ai/github-app-identity.nix  (Home Manager)
{
  pkgs,
  lib,
  privateKeyPath,
  tokenCacheDir,
}:

let
  # GIT_ASKPASS script: generates/caches GitHub App installation tokens on-demand.
  # Called by git every time it needs a password (via URL rewrite with x-access-token).
  gitAskpassScript = pkgs.writeShellScript "git-askpass-github-app" ''
    export PATH="${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.openssl
        pkgs.curl
        pkgs.gnugrep
      ]
    }"

    APP_ID="3587738"
    INSTALLATION_ID="129183080"
    PRIVATE_KEY_FILE="${privateKeyPath}"
    TOKEN_FILE="${tokenCacheDir}/predacoder-token"
    TOKEN_TTL=3300  # 55 min (token valid for 60)

    mkdir -p "${tokenCacheDir}"
    chmod 700 "${tokenCacheDir}"

    # Return cached token if still fresh
    if [ -f "$TOKEN_FILE" ]; then
      token_age=$(( $(date +%s) - $(stat -c %Y "$TOKEN_FILE") ))
      if [ "$token_age" -lt "$TOKEN_TTL" ]; then
        cat "$TOKEN_FILE"
        exit 0
      fi
    fi

    # Bail if private key not available
    if [ ! -r "$PRIVATE_KEY_FILE" ]; then
      echo "ERROR: GitHub App private key not readable at $PRIVATE_KEY_FILE" >&2
      exit 1
    fi

    # Generate JWT (valid 10 min)
    NOW=$(date +%s)
    IAT=$((NOW - 60))
    EXP=$((NOW + 540))
    HEADER=$(printf '{"alg":"RS256","typ":"JWT"}' | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')
    PAYLOAD=$(printf '{"iat":%d,"exp":%d,"iss":"%s"}' "$IAT" "$EXP" "$APP_ID" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')
    SIGNATURE=$(printf '%s.%s' "$HEADER" "$PAYLOAD" | openssl dgst -sha256 -sign "$PRIVATE_KEY_FILE" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')
    JWT="''${HEADER}.''${PAYLOAD}.''${SIGNATURE}"

    # Exchange JWT for installation token
    TOKEN=$(curl -sf -X POST \
      -H "Authorization: Bearer $JWT" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens" \
      | grep -oP '"token":\s*"\K[^"]*')

    if [ -z "$TOKEN" ]; then
      echo "Failed to generate GitHub App token" >&2
      exit 1
    fi

    # Cache and output
    printf '%s' "$TOKEN" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    printf '%s' "$TOKEN"
  '';

  # gh wrapper: injects GH_TOKEN from the same GitHub App flow.
  ghAppToken = pkgs.writeShellScriptBin "gh" ''
    export GH_TOKEN="$(${gitAskpassScript})"
    exec ${pkgs.gh}/bin/gh "$@"
  '';

  # Wrap a binary with PrêdaCoder[bot] App identity.
  # AGENT_GIT_PERSONAL=1 bypasses to use personal git identity.
  wrapWithAppIdentity =
    name: pkg:
    let
      inner = "${pkg}/bin/${name}";
    in
    pkgs.writeShellScriptBin name ''
      if [ "''${AGENT_GIT_PERSONAL:-}" = "1" ]; then
        exec ${inner} "$@"
      fi

      # App identity mode (default)
      export GIT_AUTHOR_NAME="PrêdaCoder[bot]"
      export GIT_AUTHOR_EMAIL="281405911+predacoder[bot]@users.noreply.github.com"
      export GIT_COMMITTER_NAME="PrêdaCoder[bot]"
      export GIT_COMMITTER_EMAIL="281405911+predacoder[bot]@users.noreply.github.com"
      export GIT_ASKPASS="${gitAskpassScript}"
      export GIT_TERMINAL_PROMPT=0
      export GIT_CONFIG_COUNT=2
      export GIT_CONFIG_KEY_0="url.https://x-access-token@github.com/.insteadOf"
      export GIT_CONFIG_VALUE_0="https://github.com/"
      export GIT_CONFIG_KEY_1="url.https://x-access-token@github.com/.insteadOf"
      export GIT_CONFIG_VALUE_1="git@github.com:"

      # gh wrapper: put our gh (with GH_TOKEN) before the real one
      export PATH="${ghAppToken}/bin:$PATH"

      exec ${inner} "$@"
    '';
in
{
  inherit gitAskpassScript ghAppToken wrapWithAppIdentity;
}
