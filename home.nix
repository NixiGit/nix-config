{ pkgs, lib, inputs, ... }: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.niri.homeModules.niri
  ];

  home.username = "nixidev";
  home.homeDirectory = "/home/nixidev";
  home.stateVersion = "26.05";

  # Prevent Home Manager from restarting user services during activation
  systemd.user.startServices = false;

  # Packages
  home.packages = with pkgs; [
    htop
    git
    nix-output-monitor
    nvd
    wl-clipboard
    cliphist
    pamixer
    wireplumber
    eza
    ripgrep
    fastfetch
    bat
    fzf
    btop
    zed-editor
    bash

    nixos-icons
  ];

  # XDG Links
  xdg.configFile."kitty/kitty.conf".source = ./config/kitty/kitty.conf;
  xdg.configFile."fastfetch/config.jsonc".source = ./config/fastfetch/config.jsonc;
  xdg.configFile."btop/btop.conf".source = ./config/btop/btop.conf;
  xdg.configFile."bat/config".source = ./config/bat/config;
  xdg.configFile."zed/settings.json".source = ./config/zed/settings.json;
  xdg.configFile."micro/settings.json".source = ./config/micro/settings.json;

  # Theme
  gtk = {
    enable = true;
  };

  # Terminal Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza --icons --git --group-directories-first";
      ll = "eza -l --icons --git --group-directories-first";
      tree = "eza --tree --icons";
      cat = "bat --style=plain";
      grep = "rg";
      cd = "z";
      zed = "zeditor";
    };
  };

  # Prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # Home Manager
  programs.home-manager.enable = true;

  # CLI
  programs.zoxide.enable = true;
  programs.fzf.enable = true;

  # Niri Systemd Service (fixes NVIDIA GPU race condition)
  systemd.user.services.niri = {
    Unit = {
      Description = "Niri Compositor";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };
    Service = {
      # Wait for the NVIDIA driver to initialize before starting Niri
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
      ExecStart = "${pkgs.niri}/bin/niri-session";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # DMS Lock Service (systemd-native readiness check)
  systemd.user.services.dms-lock = {
    Unit = {
      Description = "Lock screen after DMS starts";
      After = [ "niri.service" ];
      Wants = [ "niri.service" ];
    };
    Service = {
      Type = "oneshot";
      # Poll the IPC socket until DMS is ready, then lock immediately
      ExecStart = "${pkgs.bash}/bin/bash -c 'until dms ipc call lock lock 2>/dev/null; do sleep 0.5; done'";
    };
    Install.WantedBy = [ "niri.service" ];
  };

  # Niri Settings
  programs.niri.settings = {
    layout.border.enable = true;
    prefer-no-csd = true;
    hotkey-overlay = {
      skip-at-startup = true;
    };
  };
  
  programs.niri.settings.spawn-at-startup = [
    { command = [ "dms" "run" ]; }
  ];

  # DUX
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = false;
  
    niri.includes = {
      enable = true;
      override = true;
      originalFileName = "hm";
      filesToInclude = [
        "alttab"
        "binds-next"
        "binds"
        "colors"
        "cursor"
        "layout"
        "outputs"
        "windowrules"
        "wpblur"
      ];
    };
  };
}
