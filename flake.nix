{
  description = "My NixOS and Home Manager configuration";

  inputs = {
    # Nix Ecosystem
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    systems.url = "github:nix-systems/default";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # macOS
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Home manager stable — for server hosts using nixpkgs-stable
    home-manager-stable.url = "github:nix-community/home-manager/release-25.11";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    # Nix Index Database
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Common hardware modules
    hardware.url = "github:nixos/nixos-hardware";

    # Secrets management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # GSD (Get Shit Done) for Claude Code — npm release tarball, pinned by version.
    # The npm tarball is used (instead of the github tag) because it ships with
    # `hooks/dist/` pre-built via `prepublishOnly` — the github tag does not.
    # Bump with: edit the version in the URL below, then `nix flake update gsd`.
    gsd = {
      url = "https://registry.npmjs.org/get-shit-done-cc/-/get-shit-done-cc-1.34.2.tgz";
      type = "tarball";
      flake = false;
    };

    # local-rag — MCP server for semantic codebase indexing. Upstream has no tags,
    # so pin by commit SHA. Bump with: edit the SHA in the URL, then
    # `nix flake update local-rag`.
    local-rag = {
      url = "github:13W/local-rag/fb04f9191a24dec7a5d0d53431a6ef05732355d9";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      systems,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      overlays = import ./overlays { inherit inputs; };
      forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs (import systems) (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = builtins.attrValues overlays;
        }
      );

      # Overlay: pull specific packages from unstable into stable
      unstableOverlay =
        system: final: prev:
        let
          unstable = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          chromium = unstable.chromium;
          claude-code-bin = unstable.claude-code-bin;
        };
    in
    {
      inherit lib overlays;

      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        predabook = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          # > Our main nixos configuration file <
          modules = [ ./hosts/predabook ];
        };
        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/wsl ];
        };
        cloudarm = inputs.nixpkgs-stable.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/cloudarm
            { nixpkgs.overlays = [ (unstableOverlay "aarch64-linux") ]; }
          ];
        };
      };

      # macOS (nix-darwin) configuration entrypoint
      # Available through 'darwin-rebuild --flake .#your-hostname'
      darwinConfigurations = {
        mac = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/mac ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        "bruno@predabook" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux; # carries the project overlays
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/bruno/predabook.nix ];
        };
        "bruno@wsl" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/bruno/wsl.nix ];
        };
        "bruno@mac" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor.aarch64-darwin;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/bruno/mac.nix ];
        };
        "bruno@cloudarm" = home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs-stable.legacyPackages.aarch64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/bruno/cloudarm.nix ];
        };
      };
    };
}
