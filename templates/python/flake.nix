{
  description = "Python development environment";

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
              # Python toolchain
              python3
              uv

              # Linting & formatting
              ruff
              ty

              # Task runner
              just
            ];

            shellHook = ''
              echo "🐍 Python dev environment loaded"
              echo "   python: $(python3 --version)"
              echo "   uv:     $(uv --version)"
            '';
          };
        }
      );
    };
}
