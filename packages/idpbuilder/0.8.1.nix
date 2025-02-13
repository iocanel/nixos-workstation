# idpbuilder v0.8.1
{ lib
, stdenv
, fetchurl
, makeWrapper
, jdk
, pkgs ? import <nixpkgs> 
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "idpbuildeer";
  version = "0.8.1";
  os="linux";
  arch="amd64";
   

  # Use nix-prefetch-url to test the download and get the hash
  src = pkgs.fetchurl {
    url = "https://github.com/cnoe-io/idpbuilder/releases/download/v${finalAttrs.version}/idpbuilder-${finalAttrs.os}-${finalAttrs.arch}.tar.gz";
    sha256 = "06bk4mj5fzp0v00k18mmzwrh2rdhpl2lpvv8v0xc6hapdjjk49bq";
  };

  nativeBuildInputs = [ pkgs.gnutar pkgs.makeWrapper ];
  
  unpackPhase = ''
    runHook preUnpack
    mkdir -p $PWD/idpbuilder
    cp $src $PWD/idpbuilder.tar.gz
    tar -xzf idpbuilder.tar.gz -C $PWD/idpbuilder || (echo "Extraction failed" && ls -l idpbuilder.tar.gz)
    runHook postUnpack
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv idpbuilder/idpbuilder $out/bin/
    chmod +x $out/bin/*

    # Create a wrapper script
    mv $out/bin/idpbuilder $out/bin/idpbuilder.original
    makeWrapper $out/bin/idpbuilder.original $out/bin/idpbuilder \
    --set IDPBUILDER_HOME $out
  '';

  meta = with pkgs.lib; {
    description = "IDP Builder";
    homepage = "https://github.com/cnoe-io/idpbuilder";
    license = licenses.asl20;
    maintainers = with maintainers; [ "iocanel" ];
    platforms = platforms.linux;
  };
})
