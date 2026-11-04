{ config, pkgs, ... }:

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
    firefox
    kitty
    micro
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/nixidev/nix-config";
  };

  # Greeter
  services.displayManager.dux-greeter = {
    enable = true;
    compositor.name = "niri";
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
  };

  # API keys
  environment.sessionVariables = {
    OPENROUTER_API_KEY = "REDACTED";
  };

  # VPN
  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  # System State Version
  system.stateVersion = "26.05";
}
