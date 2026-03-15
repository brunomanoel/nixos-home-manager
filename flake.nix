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
      forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs (import systems) (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
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
          ollama = unstable.ollama;
          qdrant = unstable.qdrant;
          chromium = unstable.chromium;
        };
    in
    {
      inherit lib;

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
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/bruno/predabook.nix ];
        };
        "bruno@wsl" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/bruno/wsl.nix ];
        };
        "bruno@mac" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin; # Home-manager requires 'pkgs' instance
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
