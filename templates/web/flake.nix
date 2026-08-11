{
  description = "Web (SvelteKit/TypeScript) development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems f;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Runtime & package manager
              bun

              # Linting & formatting
              biome

              # Task runner
              just
            ];

            shellHook = ''
              echo "🌐 Web dev environment loaded"
              echo "   bun:   $(bun --version)"
              echo "   biome: $(biome --version)"
            '';
          };
        }
      );
    };
}
