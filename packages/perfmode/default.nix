{ stdenv, fetchzip }:
stdenv.mkDerivation {
  pname = "perfmode";
  version = "2026-02-25";

  src = fetchzip {
    url = "https://codeberg.org/icebarf/perfmode/archive/6875bb1cbd2beb9b87ad677f4afad1cc958d008d.tar.gz";
    hash = "sha256-x49I+W6wC2NkLgplg4iCGMe3lk9HJJPKMZB6D9tA1Ms=";
  };

  makeFlags = [ "PREFIX=$(out)" ];
}
