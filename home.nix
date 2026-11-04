{ pkgs, lib, inputs, ... }: {
  imports = [
      inputs.niri.homeModules.niri
      inputs.dms.homeModules.dank-material-shell
      inputs.dms.homeModules.niri
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

  # XDG
  xdg.configFile."kitty/kitty.conf".source = ./config/kitty/kitty.conf;
  xdg.configFile."fastfetch/config.jsonc".source = ./config/fastfetch/config.jsonc;
  xdg.configFile."btop/btop.conf".source = ./config/btop/btop.conf;
  xdg.configFile."bat/config".source = ./config/bat/config;
  xdg.configFile."zed/settings.json".source = ./config/zed/settings.json;

  # Theme
  gtk = {
    enable = true;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  # Shell
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

  # Compositor
  programs.niri.settings = {};

  # Shell
  programs.dank-material-shell = {
    enable = true;
    niri = {
      enableKeybinds = true;
      enableSpawn = true;
    };
  };

  # Modules
  programs.home-manager.enable = true;
  programs.zoxide.enable = true;
  programs.fzf.enable = true;
}
