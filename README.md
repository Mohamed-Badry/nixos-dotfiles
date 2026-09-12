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
| `just check` | `nix flake check --no-build --all-systems` |
| `just fmt` | `nix fmt` |
| `just lint` | `statix check .` |
| `just build` | build toplevel without switching |
| `just test` | rebuild into a test profile |
| `just switch` | rebuild and switch |
| `just boot` | rebuild, activate on next boot only |
| `just update` | `nix flake update` |
| `just clean` | keep last 5 generations, run GC |

## Inputs

Tracks `nixos-26.05`. Third-party flake inputs follow it so the system evaluates against one unified package tree, with the exception of `noctalia`, which tracks `noctalia/cachix` independently to leverage prebuilt binaries from Cachix and skip local compilation.

Binary cache substituters and keys for Noctalia are configured in `flake.nix` (`nixConfig`) and `modules/nixos/base/default.nix` (`nix.settings`), with `@wheel` included in `trusted-users`.

## Reusing on another machine

Everything under `hosts/nixos/` is machine-specific. Replace before using:

- `hardware-configuration.nix` - regenerate with `nixos-generate-config`
- `storage.nix` - Btrfs subvolume names and disk UUIDs
- `boot.nix` - GRUB has a hardcoded PopOS entry tied to this machine's EFI UUID, and blacklists `mt7921e`
- `hardware/nvidia.nix` - PRIME bus IDs, get them with `lspci`
- `hardware/asus.nix` - ASUS TUF/ROG specific quirks (fan policy, asusd, audio jack quirk); omit if non-ASUS
- host metadata in `flake.nix` (`username`, `fullName`, `email`)

`modules/` is reusable across machines, with one exception:
- `modules/home/services/mpd.nix` points `musicDirectory` and the `~/Music` link to `/media/${username}/grind/Music` (adjust to your music path if not using that Btrfs subvolume).

## Notes

- Kernel is `pkgs.linuxPackages` (stable) to avoid out-of-tree NVIDIA module build failures on newer kernels.
- 32-bit graphics (`hardware.graphics.enable32Bit = true`) is enabled for 32-bit Wine/Proton games.
- MPD listens on a UNIX domain socket (`~/.config/mpd/socket`) for RMPC, Cava visualizer, and yt-dlp integration.
- Git and Jujutsu identity come from `flake.nix` and are rendered read-only. Change them there.
- `system.stateVersion` and `home.stateVersion` are pinned. Don't bump them when the channel updates.
- Cloudflare WARP needs `warp-cli register` once after first switch to activate.
- Noctalia uses the `noctalia.cachix.org` binary cache. Running `just switch` applies `trusted-users` so unprivileged commands (`just build`) can substitute prebuilt binaries directly.
