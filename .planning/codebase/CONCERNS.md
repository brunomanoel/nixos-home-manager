# Concerns

**Analysis Date:** 2026-03-06

## Technical Debt

### Dead Code: `gpg.nix` (medium)
- **File:** `home/bruno/features/cli/gpg.nix`
- **Issue:** No longer imported anywhere (removed from `cli/default.nix` imports). File still has stale state: `enableSshSupport = true`, `defaultCacheTtlSsh`, and `ssh-add` in `loginExtra` — all now irrelevant.
- **Risk:** Confuses future maintainers who may re-add the import expecting it to work cleanly.
- **Fix:** Delete the file or strip it down to a minimal GPG-only config (no SSH support).

### Unused Flake Inputs (low)
- **File:** `flake.nix`
- **Issue:** Several inputs declared but never referenced in outputs:
  - `nixpkgs-stable` — declared, no module uses it
  - `hardware` (nixos-hardware) — declared, no host imports it
  - `nix-index-database` — declared, no host or home module imports it
- **Risk:** Unnecessary entries in `flake.lock`, longer lock file, potential confusion.
- **Fix:** Remove unused inputs or wire them up.

### Redundant Nix Formatters (low)
- **File:** `home/bruno/features/cli/default.nix`
- **Issue:** Both `alejandra` and `nixfmt` installed. They serve the same purpose.
- **Fix:** Pick one (alejandra is more commonly preferred in the Nix community).

### Old `stateVersion` (low)
- **File:** `home/bruno/global/default.nix`
- **Issue:** `home.stateVersion = lib.mkDefault "23.05"` is from 2023. Should be updated to match the current NixOS release used.
- **Risk:** Low — stateVersion only affects stateful migration logic, not package versions. But misleading.

## Fragile Areas

### `flake.lock` Out of Date for nix-darwin (high — immediate)
- **File:** `flake.lock`
- **Issue:** `nix-darwin` was added to `flake.nix` inputs but `flake.lock` hasn't been updated to include a locked revision for it. The config won't build on macOS until `nix flake lock` is run.
- **Fix:** Run `nix flake lock` (or `nix flake update nix-darwin`) to add the lock entry.

### `cuda.nix` Applied to All Linux Hosts (low)
- **File:** `hosts/common/global/default.nix` → imports `./cuda.nix`
- **Issue:** CUDA binary caches are applied globally to all Linux hosts, including WSL, which typically won't have a GPU. Adds substituters that won't be used on most hosts.
- **Risk:** Minimal (Nix ignores unavailable substituters), but it's unnecessary noise.
- **Fix:** Make CUDA opt-in via `hosts/common/optional/cuda.nix` and import only from `predabook`.

### Standalone `homeConfigurations` May Diverge (medium)
- **File:** `flake.nix`
- **Issue:** `bruno@predabook`, `bruno@wsl`, and `bruno@mac` exist as standalone `homeConfigurations` alongside the NixOS/darwin module approach. The NixOS module version (via `home-manager.users.bruno`) and the standalone version reference the same `home/bruno/<hostname>.nix` file, but they receive different `specialArgs` and may behave differently.
- **Risk:** Subtle bugs if someone uses `nh home switch` instead of `nh os switch` expecting the same result.
- **Fix:** Document clearly when to use each (see README). Consider removing the standalone entries if they aren't actively maintained.

## Security

### SSH Key Stored Unencrypted (informational)
- **File:** `home/bruno/features/cli/ssh.nix`
- **Issue:** `programs.keychain` loads `~/.ssh/github.key` at login. If this key has no passphrase, it's stored in plaintext on disk.
- **Risk:** Key compromise if disk is accessed without OS authentication.
- **Mitigation:** Use a passphrase on the key. Keychain will ask once per boot.

### `forwardAgent = true` for All Hosts (low)
- **File:** `home/bruno/features/cli/ssh.nix`
- **Issue:** Agent forwarding is enabled for all SSH connections (`matchBlocks."*"`). This means any compromised SSH server you connect to can use your agent.
- **Fix:** Restrict `ForwardAgent` to specific trusted hosts rather than `*`.

## Known Issues

### `mac.nix` is Minimal (informational)
- **File:** `home/bruno/mac.nix`
- **Issue:** Currently only imports `./global` and `./features/git.nix`. No dev tooling, no CLI features beyond the global baseline.
- **Context:** Intentional — the Mac host hasn't been set up yet. Needs to be expanded when the machine is available.

### `hosts/mac/default.nix` has No Mac-Specific Config (informational)
- **File:** `hosts/mac/default.nix`
- **Issue:** Beyond hostname and stateVersion, no Mac-specific configuration (dock, keyboard repeat, Homebrew, etc.).
- **Context:** Intentional placeholder. nix-darwin supports `system.defaults.*` for declarative macOS settings.

---

*Concerns analysis: 2026-03-06*
