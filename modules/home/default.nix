{ username, ... }:
{
  imports = [
    ./desktop/niri.nix
    ./desktop/noctalia.nix
    ./programs/shell.nix
    ./programs/terminal.nix
    ./programs/apps.nix
    ./programs/media.nix
    ./services/mpd.nix
    ./theme/default.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
    sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };
  };

  programs.home-manager.enable = true;
}
