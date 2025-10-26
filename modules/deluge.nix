{ config, pkgs, ... }: {
  services.deluge = {
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

    extraPackages = with pkgs; [
      unrar
      unzip
      gnutar
      bzip2
      xz
      p7zip
    ];
  };

  # Systemd dependencies on mount
  systemd.services.deluged = {
    after = [ "mnt-downloads.mount" "mnt-media.mount" ];
    requires = [ "mnt-downloads.mount" "mnt-media.mount" ];
  };

  systemd.services.deluge-web = {
    after = [ "mnt-downloads.mount" "mnt-media.mount" ];
    requires = [ "mnt-downloads.mount" "mnt-media.mount" ];
  };
}
