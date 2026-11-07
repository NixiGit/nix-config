{ pkgs, inputs, ... }:

let
  # ~/.zen only: nixpkgs forces MOZ_LEGACY_PROFILES=1; update if the profile resets.
  zenProfile = ".zen/jh5e32x2.Default Profile";
in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.niri.homeModules.niri
    inputs.zen-browser.homeModules.twilight
  ];

  home.username = "nixidev";
  home.homeDirectory = "/home/nixidev";
  home.stateVersion = "26.05";
  home.sessionVariables.POLZA_API_KEY = "REDACTED";

  # packages
  home.packages = with pkgs; [
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
    btop
    nixos-icons
    python3
    nixd
  ];

  # xdg
  xdg.configFile."kitty/kitty.conf".source = ./config/kitty/kitty.conf;
  xdg.configFile."fastfetch/config.jsonc".source = ./config/fastfetch/config.jsonc;
  xdg.configFile."btop/btop.conf".source = ./config/btop/btop.conf;
  xdg.configFile."bat/config".source = ./config/bat/config;
  xdg.configFile."micro/settings.json".source = ./config/micro/settings.json;

  # gtk
  gtk.enable = true;

  # shell
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
      code = "zeditor";
    };
  };

  # prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # cli
  programs.home-manager.enable = true;
  programs.zoxide.enable = true;
  programs.fzf.enable = true;

  # niri
  programs.niri.settings = {
    layout.border.enable = false;
    prefer-no-csd = true;
    hotkey-overlay.skip-at-startup = true;
    input = {
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };
      warp-mouse-to-focus.enable = true;
    };
  };
  # no spawn-at-startup: systemd owns DMS.

  # dms
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    settings.lockAtStartup = true;
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

  # zed
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "toml" "elixir" "make" ];
    userSettings = {
      # theme comes from DMS/Matugen (dank-zed-theme.json)
      theme = {
        mode = "dark";
        dark = "DankShell Dark";
        light = "DankShell Light";
      };
      buffer_font_family = "Fira Code";

      lsp.nil.binary.path = "${pkgs.nixd}/bin/nixd";

      language_models.openai_compatible.polza = {
        api_url = "https://polza.ai/api/v1";
        api_key = "REDACTED";
        available_models = [
          {
            name = "deepseek/deepseek-v4.1-flash";
            display_name = "DeepSeek V4.1 Flash";
            max_tokens = 128000;
          }
        ];
      };

      agent.default_model = {
        provider = "polza";
        model = "deepseek/deepseek-v4.1-flash";
      };

      # mcp
      context_servers = {
        fetch.command = "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch";
        filesystem = {
          command = "${pkgs.mcp-server-filesystem}/bin/mcp-server-filesystem";
          args = [ "/home/nixidev" ];
        };
        git.command = "${pkgs.mcp-server-git}/bin/mcp-server-git";
        web-search = {
          command = "${pkgs.uv}/bin/uvx";
          args = [ "duckduckgo-mcp-server" ];
        };
      };
    };
  };

  # zen
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    profiles.default.isDefault = true;
  };

  # zen css (DMS/Matugen writes ~/.config/dms/zen.css)
  home.file."${zenProfile}/chrome/userChrome.css".source = ./config/zen/userChrome.css;
  home.file."${zenProfile}/user.js".text = ''
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
  '';
}
