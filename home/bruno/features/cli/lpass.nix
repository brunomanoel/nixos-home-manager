{ pkgs, lib, ... }:
let
  # Bootstrap secrets from LastPass vault based on hostname.
  # Vault entries:
  #   GitHub/<host>      → GitHub deploy key (per-machine isolation)
  #   SSH/cloudarm       → Oracle Cloud server access key
  #   WireGuard/<host>   → WireGuard private key (stored, not auto-deployed)
  #   github.com         → GitHub MCP token (field: mcp-predabook)
  bootstrapScript = ''
    _lpass_bootstrap() {
      local host
      host=$(hostname -s)

      local need_lpass=0
      [[ ! -f "$HOME/.ssh/github.key" ]] && need_lpass=1
      [[ ! -f "$HOME/.ssh/github.pub" ]] && need_lpass=1
      [[ ! -f "$HOME/.ssh/cloudarm.key" ]] && need_lpass=1
      [[ ! -f "$HOME/.config/github-mcp/token" ]] && need_lpass=1

      [[ $need_lpass -eq 0 ]] && return 0

      echo "🔑 Bootstrapping secrets for $host..."
      mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"

      if ! lpass status --quiet 2>/dev/null; then
        echo "  ⏳ LastPass login required..."
        if ! lpass login --trust 2>/dev/null; then
          local lpass_user
          read -r -p "  📧 LastPass username: " lpass_user
          lpass login --trust "$lpass_user" || { echo "  ❌ LastPass login failed"; return 1; }
        fi
        echo "  ✅ LastPass authenticated"
      fi

      # --- GitHub key (per-machine) ---
      local gh_vault="GitHub/$host"
      local gh_priv="$HOME/.ssh/github.key"
      local gh_pub="$HOME/.ssh/github.pub"

      if [[ ! -f "$gh_priv" ]]; then
        echo "  ⏳ Fetching GitHub key from $gh_vault..."
        if lpass show --field="Private Key" "$gh_vault" 2>/dev/null > "$gh_priv"; then
          chmod 600 "$gh_priv"
          echo "  ✅ GitHub private key installed"
        else
          echo "  ❌ Could not fetch $gh_vault → Private Key"
          rm -f "$gh_priv"
        fi
      fi

      if [[ ! -f "$gh_pub" ]]; then
        if lpass show --field="Public Key" "$gh_vault" 2>/dev/null > "$gh_pub"; then
          chmod 644 "$gh_pub"
          echo "  ✅ GitHub public key installed"
        else
          echo "  ❌ Could not fetch $gh_vault → Public Key"
          rm -f "$gh_pub"
        fi
      fi

      if [[ -f "$gh_priv" ]]; then
        ssh-add "$gh_priv" 2>/dev/null && echo "  ✅ GitHub key loaded in agent"
      fi

      # --- Cloudarm key ---
      local ca_priv="$HOME/.ssh/cloudarm.key"

      if [[ ! -f "$ca_priv" ]]; then
        echo "  ⏳ Fetching cloudarm key from SSH/cloudarm..."
        if lpass show --field="Private Key" "SSH/cloudarm" 2>/dev/null > "$ca_priv"; then
          chmod 600 "$ca_priv"
          echo "  ✅ Cloudarm key installed"
        else
          echo "  ❌ Could not fetch SSH/cloudarm → Private Key"
          rm -f "$ca_priv"
        fi
      fi

      # --- GitHub MCP token ---
      local mcp_token_file="$HOME/.config/github-mcp/token"

      if [[ ! -f "$mcp_token_file" ]]; then
        local token
        token=$(lpass show --field="mcp-predabook" "github.com" 2>/dev/null)
        if [[ -n "$token" ]]; then
          mkdir -p "$HOME/.config/github-mcp"
          echo -n "$token" > "$mcp_token_file"
          chmod 600 "$mcp_token_file"
          echo "  ✅ GitHub MCP token cached"
        else
          echo "  ❌ Could not fetch GitHub MCP token"
        fi
      fi

      echo "🔑 Bootstrap complete"
    }

    _lpass_bootstrap
  '';
  # Script to bootstrap WireGuard key from LastPass (requires sudo)
  # Usage: wg-bootstrap
  wgBootstrap = pkgs.writeShellScriptBin "wg-bootstrap" ''
    set -e
    HOST=$(hostname -s)
    VAULT="WireGuard/$HOST"
    KEYFILE="/etc/wireguard/private.key"

    echo "🔐 WireGuard bootstrap for $HOST"

    if [[ -f "$KEYFILE" ]]; then
      echo "  ✅ Key already exists at $KEYFILE — skipping"
      exit 0
    fi

    echo "  ⏳ Checking LastPass..."
    if ! lpass status --quiet 2>/dev/null; then
      echo "  ⏳ Login required..."
      lpass login --trust || { echo "  ❌ Login failed"; exit 1; }
      echo "  ✅ Authenticated"
    fi

    echo "  ⏳ Fetching key from $VAULT..."
    KEY=$(lpass show --field="Private Key" "$VAULT" 2>/dev/null)
    if [[ -z "$KEY" ]]; then
      echo "  ❌ Could not fetch $VAULT → Private Key"
      exit 1
    fi

    echo "  ⏳ Installing key (sudo required)..."
    sudo mkdir -p /etc/wireguard
    echo "$KEY" | sudo tee "$KEYFILE" > /dev/null
    sudo chmod 600 "$KEYFILE"
    sudo chmod 700 /etc/wireguard
    echo "  ✅ WireGuard key installed at $KEYFILE"
    echo "🔐 Done. Restart WireGuard: sudo systemctl restart wg-quick@wg0"
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
