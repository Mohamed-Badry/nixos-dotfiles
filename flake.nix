{
  description = "Declarative NixOS and Home Manager configuration";

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

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-float-sticky = {
      url = "github:probeldev/niri-float-sticky";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
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
            ./hosts/${hostname}
            ./modules/nixos
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

      formatter = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        pkgs.writeShellApplication {
          name = "format-nix";
          runtimeInputs = [
            pkgs.findutils
            pkgs.nixfmt
          ];
          text = ''
            find . -type f -name '*.nix' -print0 | xargs -0 -r nixfmt
          '';
        }
      );

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
