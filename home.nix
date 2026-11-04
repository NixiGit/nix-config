{ pkgs, lib, inputs, ... }: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.niri.homeModules.niri
  ];

  home.username = "nixidev";
  home.homeDirectory = "/home/nixidev";
  home.stateVersion = "26.05";

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

    nixos-icons
  ];

  # XDG Links
  xdg.configFile."kitty/kitty.conf".source = ./config/kitty/kitty.conf;
  xdg.configFile."fastfetch/config.jsonc".source = ./config/fastfetch/config.jsonc;
  xdg.configFile."btop/btop.conf".source = ./config/btop/btop.conf;
  xdg.configFile."bat/config".source = ./config/bat/config;
  xdg.configFile."zed/settings.json".source = ./config/zed/settings.json;

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

  # Niri
  systemd.user.services.niri.enableDefaultPath = false;
  programs.niri.settings = {};  # Give niri-flake a valid empty set
  programs.niri.settings = {
    layout.border.enable = true;
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
