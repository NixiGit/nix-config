{ config, pkgs, lib, ... }:

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

  # boot
  boot.loader.limine.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "nvidia_drm.modeset=1" "consoleblank=0" ];

  # nix
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # locale
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

  # network
  networking.hostName = "nix";
  networking.networkmanager.enable = true;

  # users
  users.users.nixidev = {
    isNormalUser = true;
    description = "nixidev";
    extraGroups = [ "networkmanager" "wheel" "seat" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  services.seatd.enable = true;

  # packages
  environment.systemPackages = with pkgs; [
    kitty
    micro
    autologin_on_7
  ];
  programs.nix-ld.enable = true;

  # autologin
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

  # niri
  programs.niri.enable = true;
  systemd.user.services.niri.enableDefaultPath = false;
  xdg.portal.config.niri = {
    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
  };

  # audio
  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;

  # graphics
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
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    NIXOS_OZONE_WL = "1";
    WLR_DRM_DEVICES = "/dev/dri/card1";
    WLR_RENDERER = "gles2";
    GBM_BACKEND = "nvidia_drm";
    LIBVA_DRIVER_NAME = "nvidia";
    POLZA_API_KEY = "REDACTED";
    POLZA_BASE_URL = "https://polza.ai/api/v1";
  };

  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/nixidev/nix-config";
  };

  system.stateVersion = "26.05";
}
