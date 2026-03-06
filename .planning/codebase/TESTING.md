# Testing

## Overview

This is a pure Nix configuration repository (dotfiles). There is no application code, test framework, or test suite. Validation is performed through Nix evaluation and system activation.

## Validation Mechanisms

### Nix Evaluation (build-time)
Nix evaluates all `.nix` files when building. Type errors, missing attributes, and invalid options are caught at evaluation time before any changes are applied.

```bash
nix flake check
```

Checks the entire flake for evaluation errors across all configurations.

### Dry Run (pre-apply)
```bash
nh os switch --dry        # NixOS/WSL — show what would change
nh darwin switch --dry    # macOS — show what would change
nh home switch --dry      # Standalone Home Manager
```

The `--ask` flag on `nh` commands performs a dry run and prompts for confirmation before applying.

### Activation (runtime)
```bash
nh os switch       # Apply NixOS system config
nh darwin switch   # Apply nix-darwin system config
nh home switch     # Apply Home Manager config
```

Activation failures (e.g., service conflicts, missing files) surface at this stage.

## No Formal Tests

- No unit tests, integration tests, or snapshot tests
- No CI/CD pipeline defined in the repository
- Correctness is validated by successfully applying the configuration to a live system

## Linting / Formatting

Nix files can be formatted with:
```bash
alejandra .    # Nix formatter (installed via home.packages)
nixfmt .       # Alternative formatter
```
