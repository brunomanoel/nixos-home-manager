{ pkgs, lib, ... }:
let
  # Bootstrap SSH keys from LastPass vault based on hostname.
  # Vault entries:
  #   SSH/github-<host>  → GitHub deploy key (per-machine isolation)
  #   SSH/cloudarm       → Oracle Cloud server access key
  #   WireGuard/<host>   → WireGuard private key (stored, not auto-deployed)
  # Each SSH entry is a Secure Note of type "SSH Key" with fields:
  #   "Private Key" → private key content
  #   "Public Key"  → public key content
  bootstrapScript = ''
    _lpass_bootstrap_ssh() {
      local host
      host=$(hostname -s)

      # Skip if GitHub key already exists and is loaded in the agent
      if [[ -f "$HOME/.ssh/github.pub" ]] && ssh-add -l 2>/dev/null | grep -qF "$(ssh-keygen -lf "$HOME/.ssh/github.pub" 2>/dev/null | awk '{print $2}')"; then
        # Also check cloudarm key exists
        if [[ -f "$HOME/.ssh/cloudarm.key" ]]; then
          return 0
        fi
      fi

      # Authenticate if needed
      if ! lpass status --quiet 2>/dev/null; then
        echo "LastPass: login required to bootstrap SSH keys for $host"
        lpass login --trust || return 1
      fi

      # --- GitHub key (per-machine) ---
      local gh_vault="SSH/github-$host"
      local gh_priv="$HOME/.ssh/github.key"
      local gh_pub="$HOME/.ssh/github.pub"

      if [[ ! -f "$gh_priv" ]]; then
        lpass show --field="Private Key" "$gh_vault" 2>/dev/null > "$gh_priv" \
          && chmod 600 "$gh_priv" \
          || echo "LastPass: could not fetch $gh_vault → Private Key"
      fi

      if [[ ! -f "$gh_pub" ]]; then
        lpass show --field="Public Key" "$gh_vault" 2>/dev/null > "$gh_pub" \
          && chmod 644 "$gh_pub" \
          || echo "LastPass: could not fetch $gh_vault → Public Key"
      fi

      [[ -f "$gh_priv" ]] && ssh-add "$gh_priv" 2>/dev/null

      # --- Cloudarm key (shared across machines) ---
      local ca_priv="$HOME/.ssh/cloudarm.key"

      if [[ ! -f "$ca_priv" ]]; then
        lpass show --field="Private Key" "SSH/cloudarm" 2>/dev/null > "$ca_priv" \
          && chmod 600 "$ca_priv" \
          || echo "LastPass: could not fetch SSH/cloudarm → Private Key"
      fi
    }

    _lpass_bootstrap_ssh
  '';
  # Script to bootstrap WireGuard key from LastPass (requires sudo)
  # Usage: wg-bootstrap
  wgBootstrap = pkgs.writeShellScriptBin "wg-bootstrap" ''
    set -e
    HOST=$(hostname -s)
    VAULT="WireGuard/$HOST"
    KEYFILE="/etc/wireguard/private.key"

    if [[ -f "$KEYFILE" ]]; then
      echo "WireGuard key already exists at $KEYFILE"
      exit 0
    fi

    if ! lpass status --quiet 2>/dev/null; then
      echo "LastPass: login required"
      lpass login --trust || exit 1
    fi

    KEY=$(lpass show --field="Private Key" "$VAULT" 2>/dev/null)
    if [[ -z "$KEY" ]]; then
      echo "LastPass: could not fetch $VAULT → Private Key"
      exit 1
    fi

    sudo mkdir -p /etc/wireguard
    echo "$KEY" | sudo tee "$KEYFILE" > /dev/null
    sudo chmod 600 "$KEYFILE"
    sudo chmod 700 /etc/wireguard
    echo "WireGuard key installed at $KEYFILE from $VAULT"
  '';
in
{
  home.packages = with pkgs; [
    lastpass-cli
    wgBootstrap
  ];

  programs.zsh.loginExtra = lib.mkAfter bootstrapScript;
  programs.bash.profileExtra = lib.mkAfter bootstrapScript;
}
