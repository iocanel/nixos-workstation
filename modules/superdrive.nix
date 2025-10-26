{ config, pkgs, lib, ... }:

let
  unlockSuperdriveScript = pkgs.writeScript "unlock-superdrive.sh" ''
    #!${pkgs.runtimeShell}
    exec ${pkgs.sg3_utils}/bin/sg_raw /dev/sr0 EA 00 00 00 00 00 01
  '';
in {
  options.hardware.superdrive.enable = lib.mkEnableOption "Enable Apple SuperDrive unlock udev rule";
  config = lib.mkIf config.hardware.superdrive.enable {
    # Include the needed package
    environment.systemPackages = [ pkgs.sg3_utils ];

    # Add the udev rule
    services.udev.extraRules = lib.mkAfter ''
      ACTION=="add", ATTRS{idProduct}=="1500", ATTRS{idVendor}=="05ac", RUN+="${unlockSuperdriveScript}"
    '';
  };
}
