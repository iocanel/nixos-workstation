# X11/Xorg related configurations
{ config, pkgs, ... }:

{
  # SDDM display manager configuration
  services = {
    displayManager = {
      sddm = {
        enable = false;
        theme = "chili";
      };
      defaultSession = "none+i3";
    };
  };

  # SDDM PAM configuration
  security = {
    pam = {
      services = {
        sddm = {
          gnupg = {
            enable = true;
            noAutostart = true;
            storeOnly = true;
          };
        };
      };
    };
  };

  # Monitor hotplug hardware configuration
  hardware = {
    monitor-hotplug = {
      enable = true;
    };
  };

  # Monitor hotplug script
  environment.etc."udev/scripts/monitor-hotplug.sh" = {
    text = ''
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
    mode = "0755";
  };

  # Hotplug monitor systemd service
  systemd.services = {
    hotplug-monitor = {
      description = "Hotplug monitor";
      wantedBy = [ "graphical.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c /etc/udev/scripts/monitor-hotplug.sh";
        Restart = "on-failure";
      };
    };
  };

  # udev rules for hotplug
  services.udev.extraRules = ''
    # Rule to configure monitors on hotplug event
    ACTION=="add", SUBSYSTEM=="drm", RUN+="${pkgs.systemd}/bin/systemctl start hotplug-monitor.service"
  '';
}