{ config, pkgs, lib, ... }:

let
  hotplugScript = pkgs.writeShellScript "monitor-hotplug.sh" ''
    #!/bin/bash
    export DISPLAY=:0
    EXTERNAL_MON=`${pkgs.xorg.xrandr}/bin/xrandr --query | grep '\bconnected\b' | ${pkgs.gawk}/bin/awk -F" " '{print $1}' | grep -v eDP-1`
    if [ -z "$EXTERNAL_MON" ]; then
      echo "No external monitor found."
      exit 0
    fi
    echo "Setting $EXTERNAL_MON left of main."

    ${pkgs.xorg.xrandr}/bin/xrandr --output $EXTERNAL_MON --off
    ${pkgs.xorg.xrandr}/bin/xrandr --output $EXTERNAL_MON --auto --left-of eDP-1
    ${pkgs.xorg.xrandr}/bin/xrandr --output $EXTERNAL_MON --left-of eDP-1
  '';
in {
  options.hardware.monitor-hotplug.enable = lib.mkEnableOption "Enable monitor hotplug configuration";

  config = lib.mkIf config.hardware.monitor-hotplug.enable {
    # Systemd service to call the script
    systemd.services.hotplug-monitor = {
      description = "Configure monitor layout when a new monitor is hotplugged";
      wantedBy = [ "graphical.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${hotplugScript}";
        Restart = "on-failure";
      };
    };

    # Udev rule to trigger the service
    services.udev.extraRules = lib.mkAfter ''
      ACTION=="add", SUBSYSTEM=="drm", RUN+="${pkgs.systemd}/bin/systemctl start hotplug-monitor.service"
    '';
  };
}
