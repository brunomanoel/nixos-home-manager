{ pkgs, lib, ... }:
let
  # Bootstrap SSH key from LastPass vault based on hostname.
  # Vault entries: SSH/predabook, SSH/wsl, SSH/mac
  # Each entry is a Secure Note of type "SSH Key" with fields:
  #   "Private Key" → private key content
  #   "Public Key"  → public key content
  bootstrapScript = ''
    _lpass_bootstrap_ssh() {
      local host vault_entry key_priv key_pub
      host=$(hostname -s)
      vault_entry="SSH/github-$host"
      key_priv="$HOME/.ssh/github.key"
      key_pub="$HOME/.ssh/github.pub"

      # Skip if key file already exists and is loaded in the agent
      if [[ -f "$key_pub" ]] && ssh-add -l 2>/dev/null | grep -qF "$(ssh-keygen -lf "$key_pub" 2>/dev/null | awk '{print $2}')"; then
        return 0
      fi

      # Authenticate if needed
      if ! lpass status --quiet 2>/dev/null; then
        echo "LastPass: login required to bootstrap SSH key for $host"
        lpass login --trust || return 1
      fi

      # Fetch private key (SSH Key note → "Private Key" field)
      lpass show --field="Private Key" "$vault_entry" 2>/dev/null > "$key_priv" \
        && chmod 600 "$key_priv" \
        || { echo "LastPass: could not fetch $vault_entry → Private Key"; return 1; }

      # Fetch public key (SSH Key note → "Public Key" field)
      lpass show --field="Public Key" "$vault_entry" 2>/dev/null > "$key_pub" \
        && chmod 644 "$key_pub" \
        || { echo "LastPass: could not fetch $vault_entry → Public Key"; return 1; }

      ssh-add "$key_priv" 2>/dev/null
    }

    _lpass_bootstrap_ssh
  '';
in
{
  home.packages = with pkgs; [ lastpass-cli ];

  programs.zsh.loginExtra = lib.mkAfter bootstrapScript;
  programs.bash.profileExtra = lib.mkAfter bootstrapScript;
}
