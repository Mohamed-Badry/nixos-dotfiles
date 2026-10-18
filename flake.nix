{
  description = "Declarative NixOS and Home Manager configuration";

  nixConfig = {
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    niri-float-sticky = {
      url = "github:probeldev/niri-float-sticky";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia.url = "github:noctalia-dev/noctalia/cachix";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      hosts = {
        nixos = {
          system = "x86_64-linux";
          username = "crim";
          fullName = "Mohamed Badry";
          email = "m.badry.fl@gmail.com";
        };
      };

      systems = nixpkgs.lib.unique (map (host: host.system) (builtins.attrValues hosts));
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkHost =
        hostname:
        {
          system,
          username,
          fullName ? username,
          email ? null,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              email
              fullName
              inputs
              hostname
              username
              ;
          };
          modules = [
            {
              nixpkgs.overlays = [ (import ./overlays) ];
            }
            ./hosts/${hostname}
            ./modules/nixos
            inputs.nix-index-database.nixosModules.nix-index
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = {
                  inherit
                    email
                    fullName
                    inputs
                    hostname
                    username
                    ;
                };
                users.${username} = import ./modules/home;
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkHost hosts;

      packages = forAllSystems (system: import ./packages { pkgs = pkgsFor system; });

      overlays.default = import ./overlays;

      formatter = forAllSystems (system: (pkgsFor system).nixfmt-tree);

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixfmt
              nil
              statix
              just
            ];
          };
        }
      );

      templates = {
        python = {
          path = ./templates/python;
          description = "Python dev environment (uv + ruff + ty)";
          welcomeText = ''
            # Python environment ready
            Run `direnv allow` to activate, then `just --list` for commands.
          '';
        };
        web = {
          path = ./templates/web;
          description = "Web dev environment (Bun + SvelteKit + Biome)";
          welcomeText = ''
            # Web environment ready
            Run `direnv allow` to activate, then `just --list` for commands.
          '';
        };
        rust = {
          path = ./templates/rust;
          description = "Rust dev environment (stable toolchain + cargo extras)";
          welcomeText = ''
            # Rust environment ready
            Run `direnv allow` to activate, then `just --list` for commands.
          '';
        };
        typst = {
          path = ./templates/typst;
          description = "Typst document authoring (typst + tinymist)";
          welcomeText = ''
            # Typst environment ready
            Run `direnv allow` to activate, then `just --list` for commands.
          '';
        };
      };
    };
}
