{ pkgs }:
let
  inherit (pkgs) callPackage;
  qylock = callPackage ./qylock.nix { };
in
{
  plymouth-theme = callPackage ./plymouth-theme.nix { };
  inherit (qylock) lock sddmTheme;
  qylock-lock = qylock.lock;
  qylock-sddm-theme = qylock.sddmTheme;
  perfmode = callPackage ./perfmode { };
  mailspring-wrapped = callPackage ./mailspring { };
  launch-zen-vesktop = callPackage ./scripts/launch-zen-vesktop.nix { };
  smart-playerctl = callPackage ./scripts/smart-playerctl.nix { };
  toggle-scratchpad = callPackage ./scripts/toggle-scratchpad.nix { };
  obs-toggle-record = callPackage ./scripts/obs-toggle-record.nix { };
  jj-status = callPackage ./scripts/jj-status.nix { };
  yt-dlp-wrapped = callPackage ./scripts/yt-dlp-wrapped.nix { };
  asus-profile-switch = callPackage ./scripts/asus/profile-switch.nix { };
  asus-aura-sync = callPackage ./scripts/asus/aura-sync.nix { };
  asus-aura-mode = callPackage ./scripts/asus/aura-mode.nix { };
  zapfast = callPackage ./zapfast { };
}
