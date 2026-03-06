# Coding Conventions

**Analysis Date:** 2026-03-06

## Language

This repository is written entirely in **Nix** (`.nix` files) with one exception: the Neovim configuration uses **Lua** (`home/bruno/features/dev/neovim/init.lua`). There is no TypeScript, Python, or other general-purpose language present. Conventions below reflect Nix idioms.

## Naming Patterns

**Files:**
- Module files are `kebab-case.nix` (e.g., `reverse-engineer.nix`, `obs-studio.nix`, `video-edit.nix`)
- Directory entry points are always named `default.nix`
- Host-specific home-manager profiles use the hostname as the filename: `predabook.nix`, `wsl.nix`, `mac.nix`

**Directories:**
- Feature groupings use `kebab-case` (e.g., `reverse-engineer`, not used directly — single files are preferred over directories unless there are multiple files)
- Directories representing a logical unit (e.g., `neovim/`) always include a `default.nix` entry point

**Nix Attribute Names:**
- Follow Home Manager and NixOS conventions: `camelCase` for attribute names (`allowUnfree`, `enableZshIntegration`, `baseIndex`)
- `kebab-case` for option paths that are module-defined (e.g., `programs.pay-respects`, `services.gpg-agent`)
- Local `let` bindings use `camelCase` (e.g., `flakeInputs`, `ifTheyExist`, `fixGpg`)

## Function/Module Argument Patterns

**Standard module signature:** All modules accept the standard NixOS/Home Manager module argument set. Arguments are destructured at the top of the file:

```nix
# Full args — used when most args are needed
{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: { ... }

# Minimal args — used when only a few are needed
{ pkgs, ... }:
{ ... }

# let-in pattern — used for local helpers
{
  inputs,
  lib,
  pkgs,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in { ... }
```

The `...` rest argument is always present. Unused standard args (`inputs`, `outputs`, `config`) are omitted from the destructure list when not needed.

## Module Structure

**Order of top-level keys inside a module:**
1. `imports` — list of sub-modules to load
2. `home.packages` — package lists
3. `programs.*` — program configuration blocks
4. `services.*` — service configuration blocks
5. `home.*` other (e.g., `home.sessionVariables`, `home.sessionPath`)

**Imports block formatting:**
```nix
imports = [
  ./sub-module.nix
  ../other-feature
];
```

**Package lists** use `with pkgs;` for readability, with inline comments for non-obvious packages:
```nix
home.packages = with pkgs; [
  unzip
  tldr
  # Nix Tools
  comma # Runs software without installing it
  nixd  # Nix LSP
];
```

**Platform conditionals** use `lib.mkIf` and `lib.optionals` rather than if-then-else:
```nix
# Boolean gating
programs.keychain = lib.mkIf pkgs.stdenv.isLinux { ... };

# List extension
++ lib.optionals stdenv.isLinux [
  wl-clipboard
]

# Attribute value conditional
if pkgs.stdenv.isDarwin
then "/Users/${config.home.username}"
else "/home/${config.home.username}"
```

## Formatting & Style

**Formatter:** `alejandra` is installed as a dev tool (listed in `home/bruno/features/cli/default.nix` and `shell.nix`). Use it for all `.nix` formatting.

**Indentation:** 2 spaces (Nix standard, enforced by alejandra).

**Brace style:**
- Opening `{` on the same line as the attribute set or function signature
- Closing `}` on its own line at the same indentation level
- Exception: single-expression files may use `{ ... }:` on one line

**Multi-line strings** (shell scripts embedded in Nix) use `''` string literals with `/* bash */` type annotation comments for editor hinting:
```nix
let
  fixGpg = /* bash */ ''
    gpgconf --launch gpg-agent
    ssh-add ~/.ssh/github.key 2>/dev/null
  '';
in { ... }
```

**Inline config** for small program configs is acceptable inline. For non-trivial config (e.g., the full Lua config for neovim), use `builtins.readFile`:
```nix
extraLuaConfig = builtins.readFile(./init.lua);
```

## Comments

**Style:** Single-line comments use `#`. No block comments.

**When to comment:**
- Non-obvious package purposes: `comma # Runs software without installing it`
- Commented-out options that may be re-enabled: `# warn-dirty = false;`
- Section dividers: `# Nix Tools`, `# Keymaps`
- Platform-specific rationale: `# macOS Keychain: persists keys across reboots without manual ssh-add`
- Links to relevant wiki/docs: `# https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion`

**Commented-out code** is common and acceptable for options that are temporarily disabled or under consideration. They serve as documentation of explored options.

## `lib.mkDefault` Usage

Use `lib.mkDefault` for values that host-specific profiles should be able to override:
```nix
home.username = lib.mkDefault "bruno";
home.stateVersion = lib.mkDefault "23.05";
nix.package = lib.mkDefault pkgs.nix;
```

## Flake Outputs Convention

In `flake.nix`, outputs follow this pattern:
- `nixosConfigurations.<hostname>` for NixOS hosts
- `darwinConfigurations.<hostname>` for macOS hosts
- `homeConfigurations."<user>@<hostname>"` for standalone Home Manager
- `devShells` via `forEachSystem` helper

The `@inputs` pattern is used to capture the full inputs set alongside destructuring:
```nix
outputs = {
  self,
  nixpkgs,
  ...
} @ inputs: let
  ...
in { ... }
```

## Error Handling

No runtime error handling exists (this is a declarative configuration repo, not application code). The Nix evaluator itself handles errors. The only guard pattern used is the `ifTheyExist` helper in `hosts/common/users/bruno/default.nix`:
```nix
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.users.bruno.extraGroups = ifTheyExist [ "docker" "vboxusers" ... ];
}
```

This prevents evaluation failure when optional system groups are not present.

## Lua Conventions (Neovim only)

File: `home/bruno/features/dev/neovim/init.lua`

- Uses `vim.opt.*` for options (not `vim.o` or `set`)
- Uses `vim.keymap.set()` for all keymaps with a `desc` field
- Leader key is `<Space>`, mnemonic desc format `[X]oo [Y]ar` used: `{ desc = "[F]ind [F]iles" }`
- Plugins are required and set up inline at the bottom of the file
- Comments explain intent, not mechanics

---

*Convention analysis: 2026-03-06*
