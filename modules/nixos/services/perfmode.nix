{ pkgs, username, ... }:
let
  perfmode = pkgs.stdenv.mkDerivation {
    pname = "perfmode";
    version = "2026-02-25";
    src = pkgs.fetchzip {
      url = "https://codeberg.org/icebarf/perfmode/archive/96b65f3511b6ff51f6b5a354c074f09968d99826.tar.gz";
      hash = "sha256-hpCThmBq+p0FdfyDJSwMXv6s6IJWwVMtUJsSnRvGef0=";
    };
    makeFlags = [ "PREFIX=$(out)" ];
  };
in
{
  # Allow the user to run perfmode without a password
  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "${perfmode}/bin/perfmode";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Set fan to turbo mode on boot
  systemd.services.perfmode-fan-turbo = {
    description = "Set ASUS fan profile to turbo on boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${perfmode}/bin/perfmode --fan turbo";
      RemainAfterExit = true;
    };
  };
}
