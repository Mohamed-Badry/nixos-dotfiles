{ config, pkgs, ... }:
let
  # Realtek ALC256 (ASUS FX506HC, model=dell-headset-multi) exposes Headphone Jack
  # with real plug detection and Headset Mic Phantom Jack permanently on.
  # Upstream places analog-input-internal-mic (89) above analog-input-headset-mic (88)
  # and leaves both with unknown availability, so input defaults to the internal mic.
  acpPaths =
    pkgs.runCommand "alsa-card-profile-paths"
      {
        src = "${config.services.pipewire.package}/share/alsa-card-profile/mixer/paths";
      }
      ''
        cp -r "$src" "$out"
        chmod -R u+w "$out"
        substituteInPlace "$out/analog-input-headset-mic.conf" \
          --replace-fail \
            'priority = 88' \
            'priority = 95' \
          --replace-fail \
            $'[Jack Headset Mic Phantom]\nstate.plugged = unknown\nstate.unplugged = unknown\nrequired-any = any' \
            $'[Jack Headset Mic Phantom]\nrequired-any = any' \
          --replace-fail \
            $'[Jack Headphone]\nstate.plugged = unknown' \
            $'[Jack Headphone]\nstate.plugged = yes\nstate.unplugged = no'
      '';
in
{
  systemd.user.services.wireplumber.environment.ACP_PATHS_DIR = "${acpPaths}";

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire."99-deepfilter-noise-suppression" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          flags = [ "nofail" ];
          args = {
            "node.description" = "DeepFilter Noise Cancelled Mic";
            "media.name" = "DeepFilter Noise Cancelled Mic";
            "audio.rate" = 48000;
            "audio.position" = [
              "FL"
              "FR"
            ];
            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "DeepFilter Stereo";
                  plugin = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so";
                  label = "deep_filter_stereo";
                  control = {
                    "Attenuation Limit (dB)" = 75.0;
                  };
                }
              ];
            };
            "capture.props" = {
              "node.name" = "effect_input.deepfilter";
              "node.passive" = true;
            };
            "playback.props" = {
              "node.name" = "effect_output.deepfilter";
              "media.class" = "Audio/Source";
              "priority.session" = 2500;
            };
          };
        }
      ];
    };
  };
}
