{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
  pname = "maven-mvnd";
  version = "1.0-m8-m39";

  src = pkgs.fetchurl {
    url = "https://downloads.apache.org/maven/mvnd/1.0-m8/maven-mvnd-1.0-m8-m39-linux-amd64.tar.gz";
    sha256 = "sha256:8b062178ffef42c8de82cf2d8f08611bb72b4035bde13d284336e1624b67b6b9";
  };
  nativeBuildInputs = [ pkgs.gnutar pkgs.makeWrapper ];

  buildPhase = ''
    tar -xzf ${src}
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv maven-mvnd-${version}-linux-amd64/* $out/
    chmod +x $out/bin/*

    # Create a wrapper script
    mv $out/bin/mvnd $out/bin/mvnd.original
    makeWrapper $out/bin/mvnd.original $out/bin/mvnd \
      --set MVND_HOME $out
  '';

  meta = with pkgs.lib; {
    description = "Apache Maven Daemon (mvnd)";
    homepage = "https://github.com/mvndaemon/mvnd";
    license = licenses.asl20;
    maintainers = with maintainers; [ "iocanel" ];
    platforms = platforms.linux;
  };
}
