# NixOS and Home Manager configuration

This repository contains a personal NixOS flake for a Wayland desktop based on Niri, SDDM, PipeWire, Home Manager, and a small set of local packages/scripts.

The current checked-in host is named `nixos` and targets `x86_64-linux`. Several host files intentionally contain machine-specific values such as disk UUIDs, Btrfs subvolume names, bootloader entries, and NVIDIA PRIME bus IDs. Treat `hosts/nixos/` as an example host, not a reusable module.

## Repository layout

- `flake.nix` is the entry point. It defines inputs, host metadata, NixOS configurations, the formatter, and the maintenance dev shell.
- `hosts/` contains machine-specific configuration: generated hardware facts, storage, bootloader setup, GPU setup, and user creation.
- `modules/nixos/` contains reusable system-level modules: base OS settings, packages, desktop services, display manager, and keyboard remapping.
- `modules/home/` contains reusable Home Manager modules: shell, terminal tools, desktop config, application defaults, theme, and user services.
- `packages/` contains local derivations and scripts used by the system.
- `config/` contains application configuration files that are linked or copied by Home Manager.
- `assets/` contains binary assets used by local packages, such as SDDM and Plymouth theme media.
- `lib/` is reserved for repository-local Nix helpers.

## Build and maintenance commands

The flake exposes a development shell with `nixfmt`, `nil`, `statix`, and `just`:

```bash
nix develop
```

Common commands are wrapped in the `justfile`:

```bash
just check
just fmt
just lint
just test
just switch
```

Evaluate the flake without building derivations:

```bash
nix flake check --no-build --all-systems
```

Format Nix files:

```bash
nix fmt
```

Build the current host toplevel without switching:

```bash
nix build .#nixosConfigurations.nixos.config.system.build.toplevel
```

Switch the configured machine:

```bash
sudo nixos-rebuild switch --flake .#nixos
```

## Public reuse notes

Before reusing this repository on another machine, replace or parameterize:

- `hosts/nixos/hardware-configuration.nix`
- `hosts/nixos/storage.nix`
- `hosts/nixos/boot.nix`
- `hosts/nixos/hardware/nvidia.nix`
- the host metadata in `flake.nix`
- any app settings under `config/` that are personal preference rather than system requirements
- binary assets under `assets/` if their license/source is not acceptable for your fork

Do not move host-specific mounts, EFI UUIDs, or GPU bus IDs into `modules/nixos/`. Reusable modules should express capabilities; host directories should contain facts about a specific machine.

### Host caveats

- The `nixos` host assumes Btrfs subvolumes named `@nixos`, `@grind`, `@productivity`, and `@popos`.
- The PopOS subvolume is configured as a lazy systemd automount with GVFS hints, so it should appear in file managers while still mounting only on access.
- The GRUB config contains a manual PopOS boot entry tied to the current EFI UUID and PopOS path.
- NVIDIA PRIME bus IDs are machine-specific. Check them with `lspci` before reusing `hosts/nixos/hardware/nvidia.nix`.
- The host uses `linuxPackages_latest`; this is useful for current hardware and NVIDIA/Wayland fixes but is less conservative than the default kernel.
- `system.stateVersion` and `home.stateVersion` are intentionally pinned. Do not bump them just because the channel changes.

### Secrets and identity

No secrets are expected in this repository. See `SECURITY.md`.

Git and Jujutsu identity come from the host metadata in `flake.nix`:

```nix
{
  username = "crim";
  fullName = "Mohamed Badry";
  email = "m.badry.fl@gmail.com";
}
```

Since the Git and Jujutsu configs are managed declaratively (making them read-only), you must update these fields in `flake.nix` if you wish to change the identity you push to remotes.

### Assets

Code and Nix expressions are MIT licensed. Binary theme/media assets may have separate upstream licensing; see `ASSETS.md` before redistributing a fork.

## Current input policy

This branch uses `nixos-26.05` as the primary package set and passes a separate `nixpkgs-unstable` package set through module arguments as `pkgsUnstable`.

Use stable packages by default. Reach for `pkgsUnstable.<package>` only when the stable package is missing, too old, or known broken for this desktop.

## Version control

This working tree is compatible with Git and is currently managed with Jujutsu metadata. Public consumers do not need Jujutsu unless they want to use the same workflow.
