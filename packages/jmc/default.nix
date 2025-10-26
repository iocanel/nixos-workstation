# JMC 

{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "jmc";
  version = "9.1.0";

# Use nix-prefetch-url to test the download and get the hash
  src = pkgs.fetchurl {
    url = "https://github.com/adoptium/jmc-build/releases/download/${finalAttrs.version}/org.openjdk.jmc-${finalAttrs.version}-linux.gtk.x86_64.tar.gz";
    sha256 = "0l5pbsyln2fjbii3g27dxwifkz7nkgqxxhb7w36pirr6s020vsgr";
  };
  # Explicitly allow multiple directories
  sourceRoot = ".";
  nativeBuildInputs = [ pkgs.gnutar pkgs.makeWrapper ];
  
  buildPhase = ''
    tar -xzf ${finalAttrs.src}
  '';

  
  installPhase = ''
    mkdir -p $out/bin $out/lib
    tar -xzf $src
    mv JDK\ Mission\ Control/* $out/

    # Ensure the binary is executable
    chmod +x $out/jmc $out/bin/*

    # Create a wrapper script to ensure Java is set up
    makeWrapper $out/jmc $out/bin/jmc \
      --set JMC_HOME $out

    # Copy an icon if available (adjust the path if necessary)
    if [ -f $out/icon.xpm ]; then
      mkdir -p $out/share/icons/hicolor/128x128/apps/
      cp $out/icon.xpm $out/share/icons/hicolor/128x128/apps/jmc.xpm
    fi

    # Create a .desktop file
    mkdir -p $out/share/applications/
    cat > $out/share/applications/jmc.desktop <<EOF
    [Desktop Entry]
    Version=${finalAttrs.version}
    Name=JDK Mission Control
    GenericName=JMC
    Comment=Java Flight Recorder Analysis Tool
    Exec=$out/bin/jmc
    Icon=jmc
    Terminal=false
    Type=Application
    Categories=Development;Profiler;
    EOF
  '';

  meta = with pkgs.lib; {
    description = "";
    homepage = "";
    changelog = "https://github.com/adoptium/jmc-build/releases/download/${finalAttrs.version}";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.all;
    mainProgram = "jmc";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
  };
})
