{ pkgs }:

let
  deauthUsbScript = pkgs.writeText "deauth-usb.sh" ''
    #!/bin/sh
    echo 0 > "/sys/$1/authorized"
  '';

  unlockSuperdriveScript = pkgs.writeText "unlock-superdrive.sh" ''
    #!/bin/sh
    exec ${pkgs.sg3_utils}/bin/sg_raw /dev/sr0 EA 00 00 00 00 00 01
  '';
in

pkgs.runCommand "udev-scripts" { } ''
  mkdir -p $out/lib/udev/scripts

  # Install deauth-usb.sh
  cp ${deauthUsbScript} $out/lib/udev/scripts/deauth-usb.sh
  chmod +x $out/lib/udev/scripts/deauth-usb.sh

  # Install unlock-superdrive.sh
  cp ${unlockSuperdriveScript} $out/lib/udev/scripts/unlock-superdrive.sh
  chmod +x $out/lib/udev/scripts/unlock-superdrive.sh
''
