{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
  pname = "kagent";
  version = "0.6.6";
  dontUnpack = true;
  src = pkgs.fetchurl {
    url = "https://github.com/kagent-dev/kagent/releases/download/v0.6.6/kagent-linux-amd64";
    sha256 = "sha256:b57c3d971dc59fc53a9fa21a1f87c8ebb9dcb01723d26d1859af0ad08c701b5e";
  };

  buildPhase = ''
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/kagent
    chmod +x $out/bin/kagent
  '';

  meta = with pkgs.lib; {
    description = "Kagnet";
    homepage = "https://github.com/kagent-dev/kagent";
    license = licenses.asl20;
    maintainers = with maintainers; [ "iocanel" ];
    platforms = platforms.linux;
  };
}
