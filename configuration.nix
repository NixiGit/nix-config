{ config, pkgs, lib, inputs, ... }:

let
  autologin_on_7 = pkgs.autologin.overrideAttrs (_: {
    postPatch = ''
      substituteInPlace "main.c" \
        --replace-fail "setup_vt(1);" "setup_vt(7);" \
        --replace-fail "XDG_VTNR=1" "XDG_VTNR=7"
    '';
  });
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.limine.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nix";
  networking.networkmanager.enable = true;

  # Localization
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "";
  };

  # Shell
  programs.zsh.enable = true;

  # User Account
  users.users."nixidev" = {
    isNormalUser = true;
    description = "nixidev";
    extraGroups = [ "networkmanager" "wheel" "seat" ];
    shell = pkgs.zsh;
  };
  services.seatd.enable = true;

  # Packages & Flakes
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    wget
    kitty
    micro
    autologin_on_7
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/nixidev/nix-config";
  };

  # Autologin on TTY7
  systemd.services.autologin = {
    enable = true;
    restartIfChanged = lib.mkForce false;
    description = "Autologin";
    after = [ "systemd-user-sessions.service" "plymouth-quit-wait.service" ];
    serviceConfig = {
      ExecStart = "${autologin_on_7}/bin/autologin nixidev ${config.programs.niri.package}/bin/niri-session";
      Type = "simple";
      IgnoreSIGPIPE = "no";
      SendSIGHUP = "yes";
      TimeoutStopSec = "30s";
      KeyringMode = "shared";
      Restart = "always";
      RestartSec = "10";
    };
    startLimitBurst = 5;
    startLimitIntervalSec = 30;
    aliases = [ "display-manager.service" ];
    wantedBy = [ "multi-user.target" ];
  };
  security.pam.services.autologin = {
    enable = true;
    name = "autologin";
    startSession = true;
    setLoginUid = true;
    updateWtmp = true;
  };

  # Compositor
  programs.niri.enable = true;
  systemd.user.services.niri.enableDefaultPath = false;

  # Portal
  xdg.portal.config.niri = {
    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
  };

  # Graphics & Nvidia Drivers
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Fix for dynamically linked LSP binaries
  programs.nix-ld.enable = true;

  # Environment variables
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    WLR_DRM_DEVICES = "/dev/dri/card1";
    WLR_RENDERER = "gles2";
    GBM_BACKEND = "nvidia_drm";
    LIBVA_DRIVER_NAME = "nvidia";
    POLZA_AI_API_KEY = "pza-lvzZ64zjhasNU3TnzbW3eow2iJX9BUol"; 
    POLZA_BASE_URL = "https://polza.ai/api/v1";
  };

  # VPN
  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  # Nvidia Quirks & TTY Blanking
  boot.kernelParams = [ "nvidia_drm.modeset=1" "consoleblank=0" ];

  # System State Version
  system.stateVersion = "26.05";
}
