{
  description = "Rust development environment";

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
              # Rust toolchain
              rustc
              cargo
              clippy
              rustfmt
              rust-analyzer

              # Extended cargo tools
              cargo-watch
              cargo-nextest

              # System deps commonly needed by Rust crates
              pkg-config
              openssl

              # Task runner
              just
            ];

            RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

            shellHook = ''
              echo "🦀 Rust dev environment loaded"
              echo "   rustc: $(rustc --version)"
              echo "   cargo: $(cargo --version)"
            '';
          };
        }
      );
    };
}
