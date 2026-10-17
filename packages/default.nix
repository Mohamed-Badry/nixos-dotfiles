{ pkgs }:
let
  inherit (pkgs) callPackage;
  qylock = callPackage ./qylock.nix { };
  raise-or-run = callPackage ./scripts/raise-or-run.nix { };
in
{
  inherit raise-or-run;
  plymouth-theme = callPackage ./plymouth-theme.nix { };
  inherit (qylock) lock sddmTheme;
  qylock-lock = qylock.lock;
  qylock-sddm-theme = qylock.sddmTheme;
  perfmode = callPackage ./perfmode { };
  mailspring-wrapped = callPackage ./mailspring { inherit raise-or-run; };
  launch-zen-vesktop = callPackage ./scripts/launch-zen-vesktop.nix { };
  smart-playerctl = callPackage ./scripts/smart-playerctl.nix { };
  toggle-scratchpad = callPackage ./scripts/toggle-scratchpad.nix { };
  obs-toggle-record = callPackage ./scripts/obs-toggle-record.nix { };
  jj-status = callPackage ./scripts/jj-status.nix { };
  yt-dlp-wrapped = callPackage ./scripts/yt-dlp-wrapped.nix { };
  asus-profile-switch = callPackage ./scripts/asus/profile-switch.nix { };
  asus-aura-sync = callPackage ./scripts/asus/aura-sync.nix { };
  asus-aura-mode = callPackage ./scripts/asus/aura-mode.nix { };
  zapfast = callPackage ./zapfast { inherit raise-or-run; };
  autostart-apps = callPackage ./scripts/autostart-apps.nix { };
  vesktop-wrapped = callPackage ./vesktop { inherit raise-or-run; };
  focus-zen = callPackage ./scripts/focus-zen.nix { inherit raise-or-run; };
  focus-mail = callPackage ./scripts/focus-mail.nix { inherit raise-or-run; };
  niri-toggle-scroll-mode = callPackage ./scripts/niri-toggle-scroll-mode.nix { };
}
