{ stdenv, fetchzip }:
stdenv.mkDerivation {
  pname = "perfmode";
  version = "2026-02-25";

  src = fetchzip {
    url = "https://codeberg.org/icebarf/perfmode/archive/96b65f3511b6ff51f6b5a354c074f09968d99826.tar.gz";
    hash = "sha256-hpCThmBq+p0FdfyDJSwMXv6s6IJWwVMtUJsSnRvGef0=";
  };

  makeFlags = [ "PREFIX=$(out)" ];
}
