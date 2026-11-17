# Architecture & Notes

Where things live in this repo, plus custom tweaks and non-default behaviors worth knowing about so nothing feels unexpected.

### Layout

```
.
├── flake.nix                            inputs, host info, system config, packages, dev shells, templates
├── flake.lock
├── justfile                             build, check, format, lint, update, and cleanup commands
├── overlays/
│   └── default.nix                      exposes local packages under pkgs.myPkgs
├── hosts/
│   └── nixos/                           machine-specific config
│       ├── default.nix                  host imports
│       ├── hardware-configuration.nix   generated hardware & initrd config
│       ├── boot.nix                     GRUB bootloader and Sekiro theme
│       ├── storage.nix                  filesystems & Btrfs subvolumes
│       ├── user.nix                     user account & groups
│       └── hardware/
│           ├── nvidia.nix               NVIDIA PRIME offload
│           └── asus.nix                 ASUS quirks (asusd, Wi-Fi blacklist, backlight keys, audio jack)
├── modules/
│   ├── nixos/                           system modules
│   │   ├── base/                        nix settings, caches, zram swap, core CLI tools
│   │   ├── desktop/                     Niri, portals, fonts, GVFS, 32-bit graphics
│   │   └── services/                    PipeWire, keyd, Podman, Espanso, SDDM/Plymouth, responsiveness, v4l2, WARP
│   └── home/                            Home Manager modules
│       ├── desktop/                     Niri config/keybinds, Noctalia config
│       ├── programs/                    shell, terminal, apps, media, Thunar, Git & Jujutsu
│       ├── services/                    MPD, Espanso link
│       ├── theme/                       GTK (Rosé Pine), Qt (Kvantum), Bibata cursor
│       └── xdg/                         desktop entries, default apps, user folders
├── packages/                            custom packages and scripts (pkgs.myPkgs)
│   ├── default.nix                      collects everything in packages/
│   ├── plymouth-theme.nix               Hexa-retro boot splash theme
│   ├── qylock.nix                       Quickshell lockscreen & SDDM theme
│   ├── perfmode/                        perfmode power profile daemon
│   ├── mailspring/                      Mailspring wrapper (keyring + window focus)
│   ├── vesktop/                         Vesktop wrapper (RPC + Figtree font + window focus)
│   ├── zapfast/                         ZapFast WhatsApp client (pre-built binary + window focus)
│   └── scripts/                         helper scripts for Niri & ASUS hardware
│       ├── autostart-apps.nix           sets up workspaces and launches ZapFast, Vesktop, Zen
│       ├── focus-mail.nix               focus/launch Mailspring
│       ├── focus-zen.nix                focus/launch Zen
│       ├── jj-status.nix                Jujutsu prompt/status helper
│       ├── launch-zen-vesktop.nix       opens Zen + Vesktop tiled together
│       ├── obs-toggle-record.nix        OBS recording toggle
│       ├── raise-or-run.nix             focus/minimize toggle helper for app scripts
│       ├── smart-playerctl.nix          switches & controls active media players
│       ├── toggle-scratchpad.nix        toggles the Niri scratchpad terminal
│       ├── yt-dlp-wrapped.nix           audio download helper
│       └── asus/                        ASUS power profile & keyboard Aura scripts
├── config/                              plain config files used by Home Manager
├── assets/                              screenshots, wallpapers, SDDM video, Plymouth archive
└── templates/                           project flake templates (Python, Rust, web, Typst)
```

### Non-Default Behavior & Things to Know

#### System & Hardware
- **Kernel pinned to LTS/stable (`pkgs.linuxPackages`)**: Set in [boot.nix](hosts/nixos/boot.nix) so NVIDIA drivers don't break on brand-new kernels.
- **GRUB setup**: [boot.nix](hosts/nixos/boot.nix) avoids writing UEFI NVRAM entries and uses the Sekiro theme.
- **Webcam anti-flicker**: [v4l2.nix](modules/nixos/services/v4l2.nix) installs `v4l-utils` and sets the webcam to 50 Hz (`power_line_frequency=1`) when plugged in and after waking from sleep. Remove `./v4l2.nix` from [services/default.nix](modules/nixos/services/default.nix) to disable it.
- **Keyboard remaps (`keyd`)**: [keyd.nix](modules/nixos/services/keyd.nix) maps `j+k` to `Esc` and tweaks the Super/Meta key (`overload(meta, M-a)`). Remove `./keyd.nix` from [services/default.nix](modules/nixos/services/default.nix) if keys behave unexpectedly.
- **ASUS laptop quirks**: [asus.nix](hosts/nixos/hardware/asus.nix) enables `asusd`, disables the `mt7921e` Wi-Fi driver, fixes keyboard backlight keys, and applies a headset mic fix. Skip `hardware/asus.nix` on another laptop.
- **32-bit graphics**: Turned on in [modules/nixos/desktop/niri.nix](modules/nixos/desktop/niri.nix) for older Wine/Proton games.
- **Cloudflare WARP**: Enabled in [warp.nix](modules/nixos/services/warp.nix). You still have to run `warp-cli register` once after a fresh install.

#### Memory & Freezing Prevention
[responsiveness.nix](modules/nixos/services/responsiveness.nix) handles OOM protection and CPU/memory priorities (remove `./responsiveness.nix` from [services/default.nix](modules/nixos/services/default.nix) to turn all of it off):
- **Fast OOM killer (`earlyoom`)**: Replaces `systemd-oomd` (which wasn't monitoring user apps). When RAM and zram swap run low, it kills heavy browser tabs, Electron apps, or compilers first and avoids killing `niri`, Noctalia, PipeWire, or terminals. Desktop notifications appear on kills after a fresh login.
- **Process priorities (`ananicy-cpp` & systemd slices)**: Keeps `niri`, Noctalia, audio, and editors responsive while throttling compilers and `nix` rebuilds in the background.
- **No `rtkit-daemon`**: Audio permissions come from `@audio` group limits instead of `rtkit`, because `rtkit` killed `zapfast` whenever it played sound. (Takes effect for user services after logging out and back in.)
- **Zram swap**: [base/default.nix](modules/nixos/base/default.nix) sets up 50% compressed RAM swap (`zram`) with no swap partition, and [responsiveness.nix](modules/nixos/services/responsiveness.nix) tunes Linux memory settings so zram swaps cleanly before disk caches freeze the UI.

#### Desktop & Apps
- **File picker & recent files**: [modules/nixos/desktop/niri.nix](modules/nixos/desktop/niri.nix) uses the GNOME file chooser portal (kept running in the background so dialogs open fast). [theme/default.nix](modules/home/theme/default.nix) turns off GTK recent-files history.
- **Vesktop wrapper**: [packages/vesktop/default.nix](packages/vesktop/default.nix) edits `~/.config/vesktop/settings/settings.json` on startup to add a NixOS Rich Presence status, turns QuickCSS on, and writes a `:root body { --font: 'figtree'; }` block into `quickCss.css` so Discord keeps Midnight's `figtree` font instead of Noctalia's `JetBrainsMono Nerd Font`.
- **Mailspring wrapper & theme**: [packages/mailspring/default.nix](packages/mailspring/default.nix) launches Mailspring with `--password-store=gnome-libsecret`, and [apps.nix](modules/home/programs/apps.nix) copies the Catppuccin Mocha theme into `~/.config/Mailspring/packages/`.
- **Single-window toggle shortcuts**: Launching `vesktop`, `zapfast`, `mailspring`, `focus-zen`, or `focus-mail` focuses or minimizes the open window via [raise-or-run.nix](packages/scripts/raise-or-run.nix) instead of opening a second copy.
- **Thunar clipboard image paste**: [thunar.nix](modules/home/programs/thunar.nix) binds `Ctrl+Shift+V` in Thunar to save clipboard images straight into the current folder with a timestamp. Normal `Ctrl+V` still pastes files.
- **MPD & urgent script alerts**: [mpd.nix](modules/home/services/mpd.nix) uses a socket at `~/.config/mpd/socket` instead of a TCP port. Scripts like `smart-playerctl` and the ASUS hotkeys send critical notifications so they still pop up in Do Not Disturb mode.

#### Flake & Paths
- **Caches & inputs**: Flake inputs follow `nixos-26.05` except `noctalia` and `llm-agents` (kept separate so they hit their binary caches). `@wheel` is in `trusted-users`, so `just build` uses Cachix after you switch once.
- **Comma (`,`) & global compilers**: `, <cmd>` works out of the box via `nix-index-database` ([base/packages.nix](modules/nixos/base/packages.nix)), and `gcc`/`rustc`/`cargo`/`uv`/`typst` are installed globally in [apps.nix](modules/home/programs/apps.nix) alongside `templates/`.
- **Repo must live at `~/dotfiles`**: Several configs are linked straight to `~/dotfiles` so you can edit them without rebuilding. Moving the repo breaks those links until updated.
- **State versions**: `system.stateVersion` and `home.stateVersion` stay pinned at `"26.05"`. Don't bump them on updates.

### Reusing on Another Machine

Everything under `hosts/nixos/` is tied to this laptop. Update before using elsewhere:
- `hosts/nixos/hardware-configuration.nix` - regenerate with `nixos-generate-config`
- `hosts/nixos/storage.nix` - disk UUIDs and Btrfs subvolumes
- `hosts/nixos/hardware/nvidia.nix` - GPU PCI bus IDs (`lspci`)
- `hosts/nixos/hardware/asus.nix` - ASUS laptop quirks (drop if not ASUS)
- `flake.nix` - `username`, `fullName`, `email` (plus keeping the clone at `~/dotfiles`)

### Manually Pinned Packages

`just update` (`nix flake update`) updates `nixpkgs` and flake inputs; these are pinned in Nix files and have to be bumped by hand:

| Item | Location | What it is | How to Update |
| :--- | :--- | :--- | :--- |
| **ZapFast** | [packages/zapfast/default.nix](packages/zapfast/default.nix) | Pre-built WhatsApp client | Bump `version` and tarball hash |
| **Zellij Autolock** | [modules/home/programs/terminal.nix](modules/home/programs/terminal.nix) | Zellij auto-lock plugin | Bump release URL version and `sha256` |
| **perfmode** | [packages/perfmode/default.nix](packages/perfmode/default.nix) | Power profile daemon | Bump Codeberg commit and tarball hash |
| **qylock** | [packages/qylock.nix](packages/qylock.nix) | Quickshell lockscreen & SDDM theme | Bump Git `rev` and `hash` |
| **Catppuccin Mailspring** | [modules/home/programs/apps.nix](modules/home/programs/apps.nix) | Mailspring Catppuccin theme | Bump GitHub `rev` and `sha256` |
| **Sekiro GRUB theme** | [hosts/nixos/boot.nix](hosts/nixos/boot.nix) | GRUB boot menu theme | Bump GitHub `rev` and `hash` |
