# YubiKey GPG/SSH Setup Guide

This guide documents the complete YubiKey workflow for managing GPG keys and SSH access. It assumes two YubiKeys (primary + backup) and NixOS with Home Manager.

---

## Concepts

- **Master key** — the root of trust. Never used day-to-day. Kept offline.
- **Subkeys** — three subkeys derived from the master: Authentication (SSH), Signing (git commits), Encryption.
- **YubiKey** — stores the subkeys. The private subkeys never leave the YubiKey once transferred.
- **User PIN** — used for day-to-day operations (SSH, signing). Default: `123456`. Change on first use.
- **Admin PIN** — used for administrative YubiKey operations (changing PINs, importing keys). Default: `12345678`. Change on first use.
- **PUK** — unblocks the User PIN after 3 failed attempts. Store in LastPass. If PUK is also blocked, the YubiKey is permanently locked for GPG.

> **Store in LastPass:** User PIN, Admin PIN, PUK for both YubiKeys, the master key passphrase, and the master key itself (as a secure note attachment). LastPass protected by YubiKey 2FA is a sufficient security model for most use cases. Alternative: encrypted USB drive kept physically secure.

---

## 1. Initial Setup

### 1.1 Generate the master key (offline)

Do this on an air-gapped machine or at minimum on a live USB. The master key should never be stored unencrypted on a daily-use machine.

```bash
# Generate master key (certify-only, no expiration on master)
gpg --expert --full-generate-key
# Choose: (11) ECC (set your own capabilities)
# Toggle capabilities: type 's' to remove Sign, 'a' to remove Authenticate
# Only 'Certify' should remain — confirm with 'q'
# Curve: (1) Curve 25519
# Expiration: 0 (no expiration)
# Real name, email: your personal identity (primary email)
```

### 1.2 Add GitHub noreply User ID

GitHub provides a noreply email to avoid exposing your real email in commits.
Find yours at: https://github.com/settings/emails (format: `ID+username@users.noreply.github.com`)

```bash
gpg --edit-key YOUR_KEY_ID
# In gpg prompt:
adduid
# Enter: name, GitHub noreply email
uid 2          # select the new uid
trust          # set trust level
primary        # optionally set as primary
save
```

### 1.3 Add subkeys

Two subkeys — no expiration (YubiKey is the security boundary):

```bash
gpg --expert --edit-key YOUR_KEY_ID
# In gpg prompt:

# Subkey 1: GitHub (Sign + Authenticate — for GPG commits and SSH on GitHub)
addkey
# Choose: (11) ECC (set your own capabilities)
# Toggle: 's' to add Sign, 'a' to add Authenticate, 'e' to remove Encrypt
# Only Sign + Authenticate should remain — confirm with 'q'
# Curve: (1) Curve 25519
# Expiration: 0 (no expiration — YubiKey is the security boundary)

# Subkey 2: Servers (Authenticate only — for SSH on cloudarm and other servers)
addkey
# Choose: (11) ECC (set your own capabilities)
# Toggle: 'a' to add Authenticate — only Authenticate should remain — confirm with 'q'
# Curve: (1) Curve 25519
# Expiration: 0

save
```

### 1.4 Export and back up the master key

```bash
# Export master key
gpg --armor --export-secret-keys YOUR_KEY_ID > master-key-backup.asc
gpg --armor --export YOUR_KEY_ID > public-key.asc

# Print a paper backup (optional)
paperkey --secret-key master-key-backup.asc --output master-key-paper.txt
```

**Option A (recommended for this setup): Store in LastPass**
- Create a secure note in LastPass
- Attach `master-key-backup.asc` as a file attachment
- Store the passphrase in the same note
- LastPass is protected by YubiKey 2FA — sufficient security for this threat model

**Option B: Encrypted USB drive**
- Store `master-key-backup.asc` on an encrypted USB drive kept physically secure
- Never store unencrypted on cloud or daily-use machines

> When you need the master key for operations (adding UIDs, rotating subkeys), import it temporarily, perform the operation, then delete it: `gpg --delete-secret-key YOUR_KEY_ID`

### 1.5 Transfer subkeys to YubiKey 1

```bash
gpg --edit-key YOUR_KEY_ID
# In gpg prompt:
key 1          # select authentication subkey
keytocard      # transfer to YubiKey → slot 3 (Authentication)
key 1          # deselect
key 2          # select signing subkey
keytocard      # transfer → slot 1 (Signature)
key 2          # deselect
key 3          # select encryption subkey
keytocard      # transfer → slot 2 (Encryption)
save
```

> After `keytocard`, the local copy is replaced with a stub pointing to the YubiKey. The private key now lives only on the card.

### 1.6 Transfer subkeys to YubiKey 2 (backup)

Restore the master key backup first (to get real private keys back, not stubs):

```bash
gpg --import master-key-backup.asc
gpg --edit-key YOUR_KEY_ID
# Repeat keytocard for each subkey, this time with YubiKey 2 inserted
```

### 1.7 Register public key

```bash
# Export public key
gpg --armor --export YOUR_KEY_ID > public-key.asc

# GitHub: Settings → SSH and GPG keys → New GPG key → paste public-key.asc
# Servers: append SSH public key to authorized_keys
gpg --export-ssh-key YOUR_KEY_ID   # outputs SSH public key format
```

---

## 2. Day-to-Day Usage

### 2.1 New machine setup

```bash
# Import public key (no private key needed — it's on the YubiKey)
gpg --import public-key.asc
# Or fetch from keyserver
gpg --keyserver keys.openpgp.org --recv-keys YOUR_KEY_ID

# Trust the key
gpg --edit-key YOUR_KEY_ID
trust → 5 (ultimate) → save

# Plug in YubiKey — gpg-agent detects it automatically
gpg --card-status   # verify YubiKey is recognized
```

gpg-agent with `enableSshSupport = true` is already configured in the dotfiles.
`SSH_AUTH_SOCK` is set automatically via `gpgconf --launch gpg-agent` in `loginExtra`.

### 2.2 Configuring git to sign commits

```bash
git config --global user.signingkey YOUR_SUBKEY_ID!  # note the ! at the end
git config --global commit.gpgsign true
git config --global user.email "ID+username@users.noreply.github.com"  # GitHub noreply
```

---

## 3. Importing Third-Party Keys

When an employer or service provides you with an RSA/ED25519 key pair:

### 3.1 Import into GPG as an authentication subkey

```bash
# Convert the private key to GPG format and import as subkey
# Note: this key will have existed on disk — delete it afterward
gpg --expert --edit-key YOUR_KEY_ID
addkey
# Choose: (13) Existing key → provide the key file path
save
```

Then transfer to YubiKey:

```bash
gpg --edit-key YOUR_KEY_ID
# Select the newly added subkey
keytocard   # transfer to YubiKey authentication slot
save
```

### 3.2 Delete the private key from disk

```bash
# Overwrite and delete the original key file
shred -u path/to/private.key
# Verify it's gone
ls path/to/private.key
```

---

## 4. Removing Imported Third-Party Subkeys

When access is no longer needed (job change, project end):

```bash
gpg --expert --edit-key YOUR_KEY_ID
# List subkeys: key N to select the one to remove
key N
delkey      # removes the subkey from the keyring
save
```

> This removes the subkey stub from your local keyring. The YubiKey slot can be overwritten by importing a different key or resetting the card.

Also revoke access on the service side (remove from `authorized_keys`, GitHub, etc.).

---

## 5. Revoking Access to a Service

```bash
# Remove your public key from the remote server
ssh user@server "sed -i '/YOUR_KEY_FINGERPRINT/d' ~/.ssh/authorized_keys"

# GitHub: Settings → SSH and GPG keys → Delete key
```

---

## 6. SSH Forwarding (Remote Git Operations)

When SSH'd into a remote server (e.g. cloudarm) and needing to run git push:

The dotfiles already configure `ForwardAgent yes` and `remoteForwards` for gpg-agent socket forwarding.

On the remote server, ensure:

```bash
# ~/.gnupg/gpg-agent.conf
enable-ssh-support
extra-socket /run/user/1000/gnupg/S.gpg-agent.extra
```

The SSH config handles forwarding the agent socket automatically.

---

## 7. WSL Setup

WSL doesn't have direct USB access. Use `usbipd` (Windows) to forward the YubiKey:

```powershell
# Windows (admin PowerShell)
winget install usbipd
usbipd list                          # find YubiKey bus ID
usbipd bind --busid BUSID
usbipd attach --wsl --busid BUSID
```

```bash
# WSL
gpg --card-status   # verify YubiKey is recognized
```

> Run `usbipd attach` every time you plug in the YubiKey on Windows.

---

## 8. macOS Setup

Use Nix GPG (already in dotfiles) rather than GPGTools to avoid conflicts:

```bash
# Verify gpg is from Nix, not GPGTools
which gpg   # should be /etc/profiles/per-user/... or /run/current-system/...

# Import public key
gpg --import public-key.asc

# Plug in YubiKey
gpg --card-status
```

Pinentry uses `pinentry-curses` on macOS (configured in dotfiles).

---

## 9. PIN Management

| PIN | Default | Purpose | Attempts before lock |
|-----|---------|---------|---------------------|
| User PIN | `123456` | Daily operations (SSH, sign) | 3 |
| Admin PIN | `12345678` | Card admin (change PINs, import) | 3 |
| PUK | `12345678` | Unblock User PIN | 3 |

```bash
# Change PINs (do this on first use)
gpg --card-edit
passwd   # change User PIN
admin
passwd   # change Admin PIN and PUK
```

> Store all PINs and PUK in LastPass. If PUK is blocked, the YubiKey is permanently locked for GPG operations (it can be factory reset, losing all keys).

### 9.1 Unblocking a locked User PIN

```bash
gpg --card-edit
admin
unblock   # uses PUK to unblock User PIN
```

---

## 10. Subkey Rotation

Subkeys should be rotated every 1-2 years (or when expiration is reached):

```bash
# Restore master key from offline backup
gpg --import master-key-backup.asc

gpg --expert --edit-key YOUR_KEY_ID
# For each subkey: select it, set new expiration
key N
expire
# Or generate new subkeys and revoke old ones
addkey   # new subkey
key N    # select old subkey
revkey   # revoke old subkey
save

# Transfer new subkeys to both YubiKeys
# Re-export and update public key on GitHub and servers
```

---

## 11. Emergency: YubiKey Lost or Broken

1. Use the backup YubiKey immediately — same keys, same PIN
2. Order a replacement YubiKey
3. When replacement arrives, restore subkeys from master key backup and transfer to new YubiKey
4. Change PINs on the new YubiKey

---

## 12. Emergency: YubiKey Compromised

If someone had physical access to your YubiKey AND knows the PIN:

```bash
# Restore master key from offline backup
gpg --import master-key-backup.asc

# Revoke compromised subkeys
gpg --edit-key YOUR_KEY_ID
key N
revkey   # revoke the compromised subkey
save

# Generate new subkeys and transfer to both YubiKeys
# Update public key everywhere (GitHub, servers)
gpg --keyserver keys.openpgp.org --send-keys YOUR_KEY_ID
```

---

## 13. Emergency: Master Key Compromised

If the offline master key backup was exposed:

1. Revoke the entire key: `gpg --gen-revoke YOUR_KEY_ID > revocation.asc`
2. Publish revocation: `gpg --keyserver keys.openpgp.org --send-keys YOUR_KEY_ID`
3. Generate an entirely new master key and subkeys from scratch (follow Section 1)
4. Update everywhere: GitHub, all servers, git config

---

## 14. Adding an Email Address

Use this when you want to associate a new email with your existing key (e.g. new job, new GitHub account) without removing existing ones.

```bash
# Step 1: import master key from LastPass backup
gpg --import master-key-backup.asc

# Step 2: add the new User ID
gpg --edit-key YOUR_KEY_ID
# In gpg prompt:
adduid
# Enter: your name, new email address
uid N          # select the new uid (N = its number in the list)
trust          # set trust: choose 5 (ultimate, since it's your own key)
save

# Step 3: re-export and publish updated public key
gpg --armor --export YOUR_KEY_ID > public-key.asc
gpg --keyserver keys.openpgp.org --send-keys YOUR_KEY_ID

# Step 4: update LastPass with the new public-key.asc

# Step 5: delete master key from local machine
gpg --delete-secret-key YOUR_KEY_ID
```

> The YubiKey still works after this — subkeys haven't changed. Only the public key needs to be re-exported and re-uploaded to services.

## 14b. Removing an Email Address (Email Change)

```bash
# Step 1: import master key from LastPass backup
gpg --import master-key-backup.asc

gpg --edit-key YOUR_KEY_ID
uid N          # select uid to remove
deluid         # remove it
save

# Re-export and update public key
gpg --armor --export YOUR_KEY_ID > public-key.asc
gpg --keyserver keys.openpgp.org --send-keys YOUR_KEY_ID

# Delete master key from local machine
gpg --delete-secret-key YOUR_KEY_ID
```

---

## 15. Algorithm Migration

If the current algorithm (e.g. RSA 4096) is deprecated:

1. Generate new master key with new algorithm (e.g. Ed25519)
2. Sign new key with old key to establish trust chain (if possible)
3. Follow full setup process (Section 1)
4. Revoke old key after migration is complete everywhere
