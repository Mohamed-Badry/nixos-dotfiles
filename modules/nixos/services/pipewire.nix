{ pkgs, ... }:
{
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
            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  name = "DeepFilter Stereo";
                  plugin = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so";
                  label = "deep_filter_stereo";
                  control = {
                    "Attenuation Limit (dB)" = 100.0;
                  };
                }
              ];
            };
            "audio.position" = [
              "FL"
              "FR"
            ];
            "capture.props" = {
              "node.name" = "effect_input.deepfilter";
              "node.passive" = true;
            };
            "playback.props" = {
              "node.name" = "effect_output.deepfilter";
              "media.class" = "Audio/Source";
            };
          };
        }
      ];
    };
  };
}
