# NixOS configuration

This is a fresh, flake-based NixOS and Home Manager configuration.

## Layout

- `flake.nix` owns inputs, host inventory, dev shells, and outputs.
- `hosts/` holds machine facts: generated hardware, storage, bootloader, NVIDIA, and user policy.
- `modules/` holds reusable NixOS and Home Manager configuration.
- `packages/` contains local derivations such as the SDDM/Qylock theme and helper commands.
- `config/` is the single canonical source for application configuration files.
- `lib/` is reserved for shared Nix helpers.

The current host is `nixos` and is deployed with:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

For Rust work, enable direnv and enter a project using `use flake /path/to/dotfiles#rust`.

## Update policy

`nixpkgs` is the stable base. Use `pkgsUnstable.<package>` only where a newer package is actually required; do not globally replace the package set. Home Manager uses the same system package set (`useGlobalPkgs = true`).
