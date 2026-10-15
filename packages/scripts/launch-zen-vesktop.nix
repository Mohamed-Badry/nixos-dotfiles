{ writeShellApplication, niri }:
writeShellApplication {
  name = "launch-zen-vesktop";
  runtimeInputs = [ niri ];
  text = ''
    # Spawn Zen
    zen &

    # Wait for the window to appear
    sleep 2

    # The biggest Mod+R cycle is 2/3 (66.7%). Mod++ (+10%) 3 times is +30%.
    # 66.7% + 30% = 96.7%
    niri msg action set-column-width "96.7%"

    # Spawn Vesktop on the right side
    vesktop &
    sleep 2
    niri msg action set-column-width "96.7%"
  '';
}
