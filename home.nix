{ pkgs, config, inputs, ... }:

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
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.username = "nixidev";
  home.homeDirectory = "/home/nixidev";
  home.stateVersion = "26.05";
  home.sessionVariables.POLZA_API_KEY = config.sops.secrets."polza_api_key".path;

  # secrets
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/home/nixidev/.config/sops/age/keys.txt";
    secrets."polza_api_key" = { };

    # Zed's polza provider needs the literal decrypted key, so render the whole
    # settings.json at activation and link it below (see home.file).
    templates."zed-settings.json".content = ''
      {
        "theme": {
          "mode": "dark",
          "dark": "DankShell Dark",
          "light": "DankShell Light"
        },
        "buffer_font_family": "Fira Code",
        "auto_install_extensions": {
          "nix": true,
          "toml": true,
          "elixir": true,
          "make": true
        },
        "lsp": {
          "nil": {
            "binary": {
              "path": "${pkgs.nixd}/bin/nixd"
            }
          }
        },
        "language_models": {
          "openai_compatible": {
            "polza": {
              "api_url": "https://polza.ai/api/v1",
              "api_key": "${config.sops.placeholder.polza_api_key}",
              "available_models": [
                {
                  "name": "deepseek/deepseek-v4.1-flash",
                  "display_name": "DeepSeek V4.1 Flash",
                  "max_tokens": 128000
                }
              ]
            }
          }
        },
        "agent": {
          "default_model": {
            "provider": "polza",
            "model": "deepseek/deepseek-v4.1-flash"
          }
        },
        "context_servers": {
          "fetch": {
            "command": "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch"
          },
          "filesystem": {
            "command": "${pkgs.mcp-server-filesystem}/bin/mcp-server-filesystem",
            "args": [ "/home/nixidev" ]
          },
          "git": {
            "command": "${pkgs.mcp-server-git}/bin/mcp-server-git"
          },
          "web-search": {
            "command": "${pkgs.uv}/bin/uvx",
            "args": [ "duckduckgo-mcp-server" ]
          }
        }
      }
    '';
  };

  # sops renders the template at activation; link it over Zed's settings.json.
  # mkOutOfStoreSymlink keeps this pure (no absolute-path copy into the store).
  home.file.".config/zed/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."zed-settings.json".path;
    force = true;
  };

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
    layout = {
      gaps = 8;
      center-focused-column = "on-overflow";
      always-center-single-column = true;
      default-column-width.proportion = 1.0;
      preset-column-widths = [
        { proportion = 1.0; }
        { proportion = 0.5; }
        { proportion = 0.33333; }
      ];
      border.enable = false;
    };
    overview = {
      zoom = 0.5;
      backdrop-color = "#1e1e2e";
    };
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
    # settings.json comes from the sops template (see sops.templates above).
    # mutableUserSettings would jq-merge into (and clobber) that rendered file.
    mutableUserSettings = false;
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
