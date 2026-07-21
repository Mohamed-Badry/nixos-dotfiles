{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  pname = "hexa-retro-plymouth-theme";
  version = "1";
  src = ../assets/plymouth/hexa_retro.tar.gz;
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/share/plymouth/themes
    cp -r hexa_retro $out/share/plymouth/themes/
    find $out/share/plymouth/themes/hexa_retro -name '*.plymouth' \\
      -exec sed -i "s|/usr/share/plymouth/themes|$out/share/plymouth/themes|g" {} +
  '';
}
