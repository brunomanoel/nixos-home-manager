{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [ lastpass-cli ];

  programs.zsh.loginExtra = lib.mkAfter ''
    # Bootstrap SSH key from LastPass vault based on hostname.
    # Vault entries: SSH/predabook, SSH/wsl, SSH/mac
    # Each entry: private key in Notes field, public key in Username field.
    _lpass_bootstrap_ssh() {
      local host
      host=$(hostname -s)

      local key_priv="$HOME/.ssh/github.key"
      local key_pub="$HOME/.ssh/github.pub"

      # Skip if key already exists and is loaded in the agent
      if ssh-add -l 2>/dev/null | grep -qF "$key_pub"; then
        return 0
      fi

      local vault_entry="SSH/$host"

      # Authenticate if needed
      if ! lpass status --quiet 2>/dev/null; then
        echo "LastPass: login required for SSH key bootstrap"
        lpass login --trust "$(lpass ls 2>/dev/null | head -1 | grep -oP '[\w.+-]+@[\w.-]+')" 2>/dev/null \
          || lpass login --trust "$(git config user.email)"
      fi

      # Write private key
      lpass show --notes "$vault_entry" > "$key_priv" 2>/dev/null \
        && chmod 600 "$key_priv" \
        || { echo "LastPass: could not fetch $vault_entry private key"; return 1; }

      # Write public key
      lpass show --username "$vault_entry" > "$key_pub" 2>/dev/null \
        && chmod 644 "$key_pub" \
        || { echo "LastPass: could not fetch $vault_entry public key"; return 1; }

      ssh-add "$key_priv" 2>/dev/null
    }

    _lpass_bootstrap_ssh
  '';

  programs.bash.profileExtra = lib.mkAfter ''
    _lpass_bootstrap_ssh() {
      local host
      host=$(hostname -s)

      local key_priv="$HOME/.ssh/github.key"
      local key_pub="$HOME/.ssh/github.pub"

      if ssh-add -l 2>/dev/null | grep -qF "$key_pub"; then
        return 0
      fi

      local vault_entry="SSH/$host"

      if ! lpass status --quiet 2>/dev/null; then
        echo "LastPass: login required for SSH key bootstrap"
        lpass login --trust "$(git config user.email)"
      fi

      lpass show --notes "$vault_entry" > "$key_priv" 2>/dev/null \
        && chmod 600 "$key_priv" \
        || { echo "LastPass: could not fetch $vault_entry private key"; return 1; }

      lpass show --username "$vault_entry" > "$key_pub" 2>/dev/null \
        && chmod 644 "$key_pub" \
        || { echo "LastPass: could not fetch $vault_entry public key"; return 1; }

      ssh-add "$key_priv" 2>/dev/null
    }

    _lpass_bootstrap_ssh
  '';
}
