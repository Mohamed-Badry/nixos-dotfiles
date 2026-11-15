{ lib, pkgs, ... }:
let
  mkRules = type: names: map (name: { inherit name type; }) names;
in
{
  # Replace passive systemd-oomd (defaulting to no monitored user cgroups and a
  # slow 30s pressure window) with fast userspace OOM intervention + CPU/I/O
  # prioritization tailored for 15 GiB RAM + zram-only swap.
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 10;
    freeMemKillThreshold = 5;
    # Act before compressed zram saturates and triggers multi-second UI thrash.
    freeSwapThreshold = 30;
    freeSwapKillThreshold = 15;
    extraArgs = [
      # NOTE: Do not pass `-g`: niri spawns desktop apps into the same PGID as
      # the compositor, so process-group killing would tear down the session.
      "--prefer"
      (lib.concatStringsSep "|" [
        "^(Web Content"
        "Isolated Web Co"
        "Privileged Cont"
        "RDD Process"
        "Utility Process"
        "Socket Process"
        "forkserver"
        "WebExtensions"
        "chromium.*"
        "chrome"
        "electron"
        "mailspring"
        "vesktop.*"
        "node"
        "bun"
        "deno"
        "java"
        "rustc"
        "cargo"
        "rust-analyzer"
        "cc1"
        "cc1plus"
        "ld"
        "ld\\.lld"
        "lld"
        "mold"
        "python.*"
        "nix"
        "nix-store"
        "ffmpeg"
        "podman"
        "buildah)$"
      ])
      "--avoid"
      (lib.concatStringsSep "|" [
        "^(systemd"
        "systemd-.*"
        "dbus-broker.*"
        "niri"
        "niri-session"
        "niri-float-stic"
        "\\.noctalia-wrapp"
        "quickshell"
        "qs"
        "sddm"
        "sddm-helper"
        "Xwayland"
        "\\.xwayland-satel"
        "pipewire"
        "pipewire-pulse"
        "wireplumber"
        "keyd"
        "\\.espanso-wrappe"
        "wezterm-gui"
        "zellij"
        "\\.hx-wrapped"
        "fish"
        "bash"
        "sshd"
        "\\.xdg-desktop-po)$"
      ])
    ];
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;

    # Systemd slices manage cgroup CPU/IO weights; cgroup_load causes invalid
    # writes to unified cgroup v2 root /sys/fs/cgroup/cgroup.procs.
    settings = {
      cgroup_load = false;
      apply_cgroup = false;
    };

    extraTypes = [
      {
        type = "Compiler";
        nice = 15;
        sched = "batch";
        ioclass = "idle";
      }
    ];

    # Supplement CachyOS rules with NixOS-wrapped desktop/shell binaries and
    # local build/toolchain processes that are absent upstream.
    extraRules = [
      {
        name = ".noctalia-wrapped";
        nice = -8;
        ioclass = "best-effort";
        oom_score_adj = -300;
      }
      {
        name = ".noctalia-wrapp";
        nice = -8;
        ioclass = "best-effort";
        oom_score_adj = -300;
      }
      {
        name = ".xwayland-satellite";
        type = "LowLatency_RT";
        oom_score_adj = -400;
      }
      {
        name = ".xwayland-satel";
        type = "LowLatency_RT";
        oom_score_adj = -400;
      }
      {
        name = ".espanso-wrapped";
        nice = -6;
        ioclass = "best-effort";
        oom_score_adj = -200;
      }
      {
        name = ".espanso-wrappe";
        nice = -6;
        ioclass = "best-effort";
        oom_score_adj = -200;
      }
      {
        name = "niri-float-sticky";
        nice = -5;
        ioclass = "best-effort";
      }
      {
        name = "niri-float-stic";
        nice = -5;
        ioclass = "best-effort";
      }
    ]
    ++ mkRules "Doc-View" [
      ".thunar-wrapped"
      ".hx-wrapped"
      "zellij"
      ".zen-wrapped"
    ]
    ++ mkRules "Compiler" [
      "cargo"
      "rustc"
      "rust-script"
      "gcc"
      "g++"
      "cc1"
      "cc1plus"
      "clang"
      "clang++"
      "ld"
      "ld.bfd"
      "ld.gold"
      "ld.lld"
      "lld"
      "mold"
      "ar"
      "make"
      "ninja"
      "cmake"
      "ccache"
      "sccache"
      "uv"
    ]
    ++ mkRules "Heavy_CPU" [
      "rust-analyzer"
      "python3"
      "python"
      "buildah"
      "conmon"
    ];
  };

  # Grant PipeWire/WirePlumber native realtime priority via PAM limits instead
  # of rtkit-daemon: apps using fastframe_audio::realtime (e.g. zapfast) hook
  # into RTKit and get SIGKILLed by the 200ms RLIMIT_RTTIME watchdog on audio
  # output. Requires a fresh session login to propagate to user@1000.service.
  security.pam.loginLimits = [
    {
      domain = "@audio";
      type = "-";
      item = "rtprio";
      value = "95";
    }
    {
      domain = "@audio";
      type = "-";
      item = "nice";
      value = "-15";
    }
    {
      domain = "@audio";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
  ];

  # Keep Nix builds and rebuilds from starving desktop input/display.
  nix = {
    daemonCPUSchedPolicy = "batch";
    daemonIOSchedClass = "idle";
  };

  systemd = {
    oomd.enable = false;

    services.nix-daemon.serviceConfig = {
      Nice = 15;
      CPUWeight = 20;
      IOWeight = 20;
      OOMScoreAdjust = 100;
    };

    # Prioritize core Wayland session/audio slices over apps and background jobs.
    slices = {
      user.sliceConfig = {
        CPUWeight = 100;
        IOWeight = 100;
      };
      system.sliceConfig = {
        CPUWeight = 80;
        IOWeight = 80;
      };
    };

    user = {
      slices = {
        session.sliceConfig = {
          CPUWeight = 500;
          IOWeight = 500;
          MemoryLow = "1G";
        };
        app.sliceConfig = {
          CPUWeight = 100;
          IOWeight = 100;
        };
        background.sliceConfig = {
          CPUWeight = 20;
          IOWeight = 20;
        };
      };

      services.niri.serviceConfig.OOMScoreAdjust = -500;
    };
  };

  boot.kernel.sysctl = {
    # Zram-only tuning: compress cold anonymous pages proactively instead of
    # evicting hot UI/filesystem page cache, and disable multi-page swapahead.
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;

    # Cap writeback accumulation so heavy I/O doesn't stall Btrfs flushes.
    "vm.dirty_background_bytes" = 67108864;
    "vm.dirty_bytes" = 268435456;
  };
}
