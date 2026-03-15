{ pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Enable flakes and the new nix command.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Basic user account setup.
  users.users.odie = {
    isNormalUser = true;
    description = "Odie";
    extraGroups = [ "networkmanager" "wheel" "docker" ]; # 'wheel' for sudo
    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Networking
  networking.networkmanager.enable = true;

  # Upower
  services.upower.enable = true;

  # Enable sound with PipeWire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
    #jack.enable = true;
    extraConfig.pipewire-pulse."10-adjustQuirkRules.conf" = {
      "pulse.rules" = [
        {
          matches = [
            { "application.process.binary" = "teams"; }
            { "application.process.binary" = "teams-insiders"; }
            { "application.process.binary" = "skypeforlinux"; }
          ];
          actions = { quirks = [ "force-s16-info" ]; };
        }
        {
          matches = [ { "application.process.binary" = "firefox"; } ];
          actions = { quirks = [ "remove-capture-dont-move" ]; };
        }
        {
          matches = [ { "application.name" = "~speech-dispatcher.*"; } ];
          actions = {
            "update-props" = {
              "pulse.min.req" = "512/48000";
              "pulse.min.quantum" = "512/48000";
              "pulse.idle.timeout" = 5;
            };
          };
        }
        {
          matches = [ { "application.name" = "~Chromium.*"; } ];
          actions = { quirks = [ "block-source-volume" ]; };
        }
        {
          matches = [ { "application.process.binary" = "Discord"; } ];
          actions = { quirks = [ "block-source-volume" ]; };
        }
        {
          matches = [ { "application.process.binary" = "vesktop"; } ];
          actions = { quirks = [ "block-source-volume" ]; };
        }
      ];
    };
  };
  
  # Bluetooth
  services.blueman.enable = true;
  services.flatpak.enable = true;

  programs.nix-ld.enable = true;
  programs.java.enable = true;
  # Sets up libraries required by Android SDK binaries
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    ncurses5

    # GPU/graphics libs for Android Emulator hardware acceleration
    libGL
    libGLU
    vulkan-loader
    libdrm
    mesa

    # X11/Wayland libs the emulator needs
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libXext
    xorg.libXfixes
    xorg.libxcb
    wayland

    # Other common deps for Android tooling
    libpulseaudio
    alsa-lib
    nss
    nspr
    expat
    glib
    dbus
    systemd
    freetype
    fontconfig
  ];

  # Automount
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Printing
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
      pkgs.brlaser
    ];
  };

  # This creates a security wrapper for gpu-screen-recorder to allow it
  # to use the KMS backend for high-performance recording.
  security.wrappers."gsr-kms-server" = {
    source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
    capabilities = "cap_sys_admin+ep";
    owner = "root";
    group = "root";
  };


  # For docker
  virtualisation.docker = {
    enable = true;
  };

  programs.fish.enable = true;  

  # Core packages you always want available.
  environment.systemPackages = with pkgs; [
    git
    wget
    vim
    cifs-utils
  ];

  # SMB Mount
  fileSystems."/mnt/das" = {
    device = "//10.0.1.1/das";
    fsType = "cifs";
    options = let
      # PRevent hangs
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
  };

  xdg = {
    autostart.enable = true;
    mime = {
      defaultApplications = {
        "inode/directory" = [ "nautilus.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http"  = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    };

    portal = {
      enable = true;
      config = {
        common.default = ["gtk"];
        hyprland = {
          default = ["gtk" "hyprland"];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
        };
      };
      extraPortals = [
        pkgs.xdg-desktop-portal
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}
