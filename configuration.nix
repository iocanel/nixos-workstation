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

{ config, pkgs, fetchFromGithub, ... }:
  let
    #
    # Define the paths to your custom packages
    #
    mvnd = pkgs.callPackage /etc/nixos/packages/mvnd/default.nix { };
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
  };
    
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.fish;
    users.iocanel = {
      isNormalUser = true;
      description = "Ioannis Canellos";
      extraGroups = [ "root" "wheel" "audio" "video" "docker" "networkmanager" ];
    };
  };

  home-manager = {
    users.iocanel = /home/iocanel/.config/home-manager/home.nix;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Overlays
   nixpkgs.overlays = [
    (import /etc/nixos/overlays/custom-java-overlay.nix)
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
     #
     # Containers
     #
     docker
     docker-machine-kvm2
     docker-compose
     #
     # Drivers
     #
     brlaser

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
     maven
     gradle
     temurin-bin-17
     jbang
     quarkus
     # Javascript
     nodejs
     nodejs_18
     yarn-berry
     # Go
     go
     # Python
     python312
     poetry
     # Rust
     rustup
     cargo
     # SQL
     sqlite
     # Utils
     gnuplot
     #
     # Editors
     #
     neovim
     emacs
     #
     # Fonts
     #
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
     #
     # Kubernetes
     #
     kubectl
     k9s
     kubernetes-helm
     kind
     minikube
     #
     # Desktop environments
     #
     arandr
     i3
     i3blocks
     sddm
     sddm-chili-theme
     #
     # Multimedia
     #
     pulseaudio
     pavucontrol
     pa_applet
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
     firefox
     chromium
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
     # Tools
     unzip
     unrar
     rsync
     # System tools
     pciutils
     usbutils
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
        load-module module-switch-on-port-available
        load-module module-udev-detect
        load-module module-detect
        load-module module-alsa-source device=hw:0,0
      '';
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
 

  # Open ports in the firewall.
  networking = {
    firewall = {
      enable = false;
      allowedTCPPorts = [ 22 80 443 8080 8096 8920 ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";

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
      emby-server = {
        description = "Emby Server";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "docker.service" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.docker}/bin/docker run -d --name emby-server -e UID=1000 -e GUID=100 -e GIDLIST=100 -p 8096:8096 -p 8920:8920 -v /home/iocanel/.config/emby/:/config -v /mnt/media:/mnt/media --cpus=2 --memory=4g --restart on-failure emby/embyserver:4.9.0.26";
          ExecStop = "${pkgs.docker}/bin/docker rm -f emby-server";
          RemainAfterExit = true;
        };
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
          matchConfig.Name = "en*";
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

  #
  # udev
  #
  services.udev.extraRules = ''
    # Rule to deauthorize USB device
    ACTION=="add", SUBSYSTEM=="usb", RUN+="${pkgs.bash}/bin/bash -c echo 0 > /sys/$devpath/authorized"

    #
    # Work in progress
    #

    # Rule to configure monitors on hotplug event
    ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${pkgs.bash}/bin/bash -c xrandr --query | grep connect | awk '{print $1}' | while read monitor; do xrandr --output $monitor --auto; done"

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

