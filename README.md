# NixOS configuration

Personal NixOS flake. Single host (`nixos`, `x86_64-linux`) running a Wayland desktop on Niri, SDDM, and PipeWire, managed with Home Manager.

## Layout

```
.
├── flake.nix                   entry point: inputs, host metadata, nixosSystem call
├── flake.lock
├── justfile                    common maintenance commands
├── hosts/
│   └── nixos/                  machine-specific facts (disk UUIDs, bus IDs, etc.)
│       ├── boot.nix            bootloader, kernel
│       ├── storage.nix         filesystems, Btrfs subvolumes
│       ├── user.nix            user account creation
│       └── hardware/
│           ├── nvidia.nix      NVIDIA PRIME offload setup
│           └── asus.nix        board-specific quirks (audio, etc.)
├── modules/
│   ├── nixos/                  system-level modules
│   │   ├── base/               nix settings, core packages
│   │   ├── desktop/            Niri compositor, PipeWire, GVFS
│   │   └── services/           keyd, perfmode, SDDM, Cloudflare WARP
│   └── home/                   Home Manager modules
│       ├── desktop/            Niri config, Noctalia bar
│       ├── programs/           shell, terminal, apps, media
│       ├── services/           MPD
│       └── theme/              GTK/icon theme
├── packages/                   local derivations (Plymouth theme, qylock, scripts)
├── config/                     app config files linked by Home Manager
├── assets/                     binary theme media (SDDM, Plymouth)
└── templates/                  dev shells for Python, Rust, web, Typst
```

## Commands

Enter the dev shell to get `just`, `nixfmt`, `nil`, and `statix`:

```bash
nix develop
```

| Command | What it does |
| --- | --- |
| `just check` | `nix flake check --no-build` |
| `just fmt` | `nix fmt` |
| `just lint` | `statix check .` |
| `just build` | build toplevel without switching |
| `just test` | rebuild into a test profile |
| `just switch` | rebuild and switch |
| `just boot` | rebuild, activate on next boot only |
| `just update` | `nix flake update` |
| `just clean` | keep last 5 generations, run GC |

## Inputs

Only `nixos-26.05`. All third-party flake inputs follow it directly so the whole system evaluates against one package tree.

## Reusing on another machine

Everything under `hosts/nixos/` is machine-specific. Replace before using:

- `hardware-configuration.nix` - regenerate with `nixos-generate-config`
- `storage.nix` - Btrfs subvolume names and disk UUIDs
- `boot.nix` - GRUB has a hardcoded PopOS entry tied to this machine's EFI UUID
- `hardware/nvidia.nix` - PRIME bus IDs, get them with `lspci`
- host metadata in `flake.nix` (`username`, `fullName`, `email`)

`modules/` is reusable. `hosts/` is not.

## Notes

- Kernel is `pkgs.linuxPackages` (stable) to avoid out-of-tree NVIDIA module build failures on newer kernels.
- Git and Jujutsu identity come from `flake.nix` and are rendered read-only. Change them there.
- `system.stateVersion` and `home.stateVersion` are pinned. Don't bump them when the channel updates.
- Cloudflare WARP needs `warp-cli register` once after first switch to activate.
