#
# My NixOS configuration
#

#
# Requirements:
#
# 1. home manager
#    $ nix-channel --add https://github.com/nix-community/home-manager/archive/release-24-05.tar.gz home-manager
#    $ nix-channel --update
# 

#
# After performing changes
# $ sudo nixos-rebuild switch
# $ sudo nixos-rebuild --install-bootloader boot

# Cleaning up
# $ nix-env --delete-generations 3d


#
# To GC old generations:
# $ nix-env --delete-generations 7d
#

{ config, pkgs, fetchFromGithub, ... }:
  let
    #
    # Define the paths to your custom packages
    #
    mvnd = pkgs.callPackage /etc/nixos/packages/mvnd/default.nix { };
    quarkus-cli = pkgs.callPackage /etc/nixos/packages/quarkus-cli/default.nix { };
    quarkus-cli-3-14-3 = pkgs.callPackage /etc/nixos/packages/quarkus-cli/3-14-3.nix { };
    quarkus-cli-3-14-4 = pkgs.callPackage /etc/nixos/packages/quarkus-cli/3-14-4.nix { };
    idpbuilder = pkgs.callPackage /etc/nixos/packages/idpbuilder/0.8.1.nix { };
  in
{
  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.grub.enable = false;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.systemd-boot.enable = true;
  networking.hostName = "nixos"; # Define your hostname.
  
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable networkd
  networking.useNetworkd = true;

  # Set your time zone.
  time.timeZone = "Europe/Athens";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "el_GR.UTF-8";
    LC_IDENTIFICATION = "el_GR.UTF-8";
    LC_MEASUREMENT = "el_GR.UTF-8";
    LC_MONETARY = "el_GR.UTF-8";
    LC_NAME = "el_GR.UTF-8";
    LC_NUMERIC = "el_GR.UTF-8";
    LC_PAPER = "el_GR.UTF-8";
    LC_TELEPHONE = "el_GR.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services = {
    # Configure keymap in X11
    xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = true;
      };
      displayManager = {
      	gdm = {
	        enable = false;
	      };
      };
      windowManager = {
        i3 = {
          enable = true;
          extraPackages = with pkgs; [
            dmenu
	          rofi
	          i3lock
	          i3blocks
          ];
        };
      };
      xkb = {
        variant = "";
        options = "grp:alt_shift_toggle";
        layout = "us,gr";
      };
    };
    
    udisks2 = {
      enable = true;
    };
    
    pipewire = {
      enable = false;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    displayManager = {
      defaultSession = "none+i3";
      sddm = {
        enable = true;
        theme = "chili";
      };
    };

    clipmenu.enable = true;
    openssh.enable = true;
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    # Media Server
    deluge = {
      enable = true;
      web = {
        enable = true;
        port = 8112;
        openFirewall = true;
      };
      config = {
        download_location = "/mnt/downloads/";
        max_upload_speed = "1000.0";
        share_ratio_limit = "2.0";
        allow_remote = true;
        daemon_port = 58846;
        listen_ports = [ 6881 6889 ];
      };
      extraPackages = with pkgs; [unrar unzip gnutar bzip2 xz p7zip ];
    };
  };
    
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.fish;
    users.iocanel = {
      isNormalUser = true;
      description = "Ioannis Canellos";
      extraGroups = [ "root" "wheel" "audio" "video" "docker" "networkmanager" "disk" "transmission" "deluge" ];
    };
  };

  home-manager = {
    users.iocanel = /home/iocanel/.config/home-manager/home.nix;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
     "dotnet-sdk-6.0.428"
  ];

  # Experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Overlays
   nixpkgs.overlays = [
    (import /etc/nixos/overlays/custom-java-overlay.nix)
    (import /etc/nixos/overlays/emacs-xwidgets-overlay.nix)
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     stdenv # nixos build essentials
     home-manager
     bash
     zsh
     fish
     direnv
     pass
     pinentry-curses
     pinentry-qt
     stow
     #
     # AI
     #
     ollama
     #
     # Clipboard Management
     #
     clipmenu
     clipnotify
     xclip
     xsel
     #
     # Containers
     #
     docker
     docker-buildx
     docker-machine-kvm2
     docker-compose
     #
     # Drivers
     #
     brlaser
     #
     # Editors
     #
     emacs
     neovim
     #
     # Development
     #
     git
     gnumake
     # C
     gcc
     glibc
     cmake
     libtool
     # Java
     temurin-bin-21
     maven
     gradle
     jbang
     quarkus-cli
     # Javascript
     nodejs
     nodejs_18
     yarn-berry
     # Go
     go
     # Python
     python311
     poetry
     
     # Rust
     rustup
     rustc
     rustfmt
     cargo
     # Suggested by:  https://github.com/NixOS/nixpkgs/blob/0109d6587a587170469cb11afc18a3afe71859a3/doc/languages-frameworks/rust.section.md#using-the-rust-nightlies-overlay
     binutils
     pkg-config
     

     # SQL
     sqlite
     # Utils
     #Devices
     sg3_utils
     #
     # Graphics
     #
     gnuplot
     #
     # Kubernetes
     #
     kubectl
     k9s
     kubernetes-helm
     kind
     minikube
     idpbuilder
     #
     # Desktop environments
     #
     xorg.xhost
     i3
     i3blocks
     sddm
     sddm-chili-theme
     #
     # Multimedia
     #
     pulseaudio
     pavucontrol
     nitrogen
     ffmpeg
     v4l-utils
     guvcview
     mpv
     gimp
     opencv
     audacity
     obs-studio
     kdenlive
     vocal
     newsflash
     #
     # Network and Internet
     #
     zulip
     slack
     discord
     dropbox
     remmina
     wget
     curl
     wireshark
     openvpn
     networkmanager-openvpn
     networkmanagerapplet
     openssl
     bluez
     #
     # Office
     #
     libreoffice
     texliveFull
     obsidian
     #
     # Terminal
     #
     alacritty
     rxvt-unicode
     xterm
     # Terminal UI
     fzf
     ripgrep
     bat
     eza
     dust
     htop
     # Media Center     
     deluge
     # Tools
     unzip
     unrar
     p7zip
     rsync
     udiskie
     # System tools
     lsof
     pciutils
     usbutils
     pam_gnupg
     libnotify
     
     # Overrides
     dotnet-sdk
  ];

  fonts.packages = with pkgs; [
     font-awesome
     nerdfonts
     hack-font
     fira-code
     powerline-fonts
     material-icons
     material-design-icons
     source-code-pro
     inconsolata
     dejavu_fonts
     fg-virgil

  ];
  programs = {
    nix-ld = {
      enable = true;
    };

    gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        vi = "nvim";
        update = "sudo nixos-rebuild switch";
      };
    };

    fish = {
      enable = true;
    };

    java = {
      enable = true;
    };
    
  };

  #
  # Hardware
  #
  hardware = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
        load-module module-switch-on-port-available
        load-module module-detect
      '';
      
      # Disabled extraConfig
      #  load-module module-udev-detect
      #  load-module module-alsa-source device=hw:0,0
      #  load-module module-combine-sink
    };
  };

  #
  # Printing
  #

  #
  # Virtualisation
  #
  virtualisation.docker.enable=true;
  virtualisation.docker.storageDriver="overlay2";
  virtualisation.docker.daemon.settings.ipv6 = false;

  # Open ports in the firewall.
  networking = {
    firewall = {
      enable = false;
      allowedTCPPorts = [
        22   #SSH
        80   # HTTP
        443  # HTTPS

        8008 # WEB APP
        8443 # SECURE WEB APP
        
        8920 # EMBY SERVER
        8989 # SONARR
        7878 # RADARR
        6767 # BAZARR
        9117 # JACKET
        6881 # DELUGE
        6891 # DELUGE
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";

  systemd = {
    services = {
      fc-cache-update = {
        description = "Update font cache";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.fontconfig}/bin/fc-cache -fv'";
          RemainAfterExit = true;
        };
      };
      hotplug-monitor = {
        description = "Hotplug monitor";
        wantedBy = [ "graphical.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c /etc/udev/scripts/monitor-hotplug.sh";
          Restart = "on-failure";
        };
      };
      emby-server = {
        description = "Emby Server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "docker.service" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.docker}/bin/docker run -d --name emby-server -e UID=1000 -e GUID=100 -e GIDLIST=100 -p 8096:8096 -p 8920:8920 -v /home/iocanel/.config/emby/:/config -v /mnt/media:/mnt/media --cpus=2 --memory=4g --restart on-failure emby/embyserver:4.9.0.26";
          ExecStop = "${pkgs.docker}/bin/docker kill emby-server && ${pkgs.docker}/bin/docker rm -f emby-server";
          RemainAfterExit = true;
        };
      };
      check-media-mount = {
        description = "Start/Stop media services based on mount status";
        after = [ "network.target" ];
        serviceConfig = {
          ExecStart = "/etc/local/bin/check-media-mounts.sh";
          Type = "oneshot";
          RemainAfterExit = true; # Prevents the service from being re-triggered unnecessarily
          TimeoutStartSec = "30s";
        };
        wantedBy = [ "check-media-mount.path" ];
      };
    };
    
    paths = {
      check-media-mount = {
        description = "Monitor media mounts";
        pathConfig = {
          PathExists = "/mnt/media/healthcheck";  # Change this to your actual mount point
        };
        wantedBy = [ "multi-user.target" ];
      };
    };

    network = {
      enable = true;
      # netdevs = {
      #   br1 = {
      #      netdevConfig = {
      #       Kind = "bridge";
      #      Name = "br1";
      #    };
      #   };
      # };
      networks = {
        eth1 = {
          matchConfig.Name = "enp82s0u2u1u2";
          DHCP = "ipv4";
        };

       # br1 = {
       #   matchConfig.Name = "br1";
       #   DHCP = "ipv4";
       # };
       # br1-bind = {
       #   matchConfig.Name = "en*";
       #   networkConfig.Bridge="br1";
       # };
      };
    };
  };

  security = {
    pam = {
      services = {
        login = {
          gnupg = {
            enable = true;
            noAutostart = true;
            storeOnly = true;
          };          
        };
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
  
  environment.variables = {
    DOCKER_BUILDKIT = 1;  # Globally enable BuildKit
  };

  #
  # udev
  #
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


  services.udev.extraRules = ''
    # Rule to deauthorize USB device
    ACTION=="add", SUBSYSTEM=="usb", RUN+="${pkgs.bash}/bin/bash -c echo 0 > /sys/$devpath/authorized"

    #
    # Work in progress
    #

    # Rule to configure monitors on hotplug event
    ACTION=="add", SUBSYSTEM=="drm", RUN+="${pkgs.systemd}/bin/systemctl start hotplug-monitor.service"

    # Rule to configure apple superdrive
    ACTION=="add", ATTRS{idProduct}=="1500", ATTRS{idVendor}=="05ac", DRIVERS=="usb", RUN+="${pkgs.sg3_utils}/bin/sg_raw %r/sr%n EA 00 00 00 00 00 01"

    # Rule to ignore /dev/video5 as it is not working properly
    KERNEL=="video5", SUBSYSTEM=="video4linux", OPTIONS+="ignore_device"
  '';

  #
  # Package activation
  #

  # Create a symlink for /bin/bash
  environment.etc."bash".source = "${pkgs.bash}/bin/bash";
  # Alternatively, use system activation script to create the symlink
  system.activationScripts.bash = {
    text = ''
      mkdir -p /bin
      ln -sf ${pkgs.bash}/bin/bash /bin/bash
    '';
  };
}

