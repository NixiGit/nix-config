{ config, pkgs, lib, inputs, ... }: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.niri.homeModules.niri
    inputs.matugen.nixosModules.default
    inputs.zen-browser.homeModules.twilight
  ];

  home.username = "nixidev";
  home.homeDirectory = "/home/nixidev";
  home.stateVersion = "26.05";

  # Inject the verified working API key
  home.sessionVariables = {
    POLZA_API_KEY = "REDACTED";
  };

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
    bash
    nixos-icons
    python3
    nixd
    uv 
    mcp-server-fetch 
    mcp-server-filesystem 
    mcp-server-git 
  ];

  # XDG Links
  xdg.configFile."kitty/kitty.conf".source = ./config/kitty/kitty.conf;
  xdg.configFile."fastfetch/config.jsonc".source = ./config/fastfetch/config.jsonc;
  xdg.configFile."btop/btop.conf".source = ./config/btop/btop.conf;
  xdg.configFile."bat/config".source = ./config/bat/config;
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
      code = "zeditor";
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

  # Niri Settings
  programs.niri.settings = {
    layout.border.enable = false;
    prefer-no-csd = true;
    hotkey-overlay = {
      skip-at-startup = true;
    };
    input = {
      focus-follows-mouse = {
        enable = true;
        max-scroll-amount = "0%";
      };
      warp-mouse-to-focus.enable = true;
    };
  };
  
  # NOTE: NO spawn-at-startup FOR DMS. Systemd handles it.

  # DUX
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

  # --- Zed Editor + Polza AI + MCP Servers ---
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "toml" "elixir" "make" ];
    userSettings = {
      theme = "One Dark";
      buffer_font_family = "Fira Code";
      
      lsp = {
        nil = {
          binary.path = "${pkgs.nixd}/bin/nixd";
        };
      };
      
      language_models = {
        openai_compatible = {
          polza = {
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
        };
      };

      agent = {
        default_model = {
          provider = "polza";
          model = "deepseek/deepseek-v4.1-flash";
        };
      };

      # Context servers (MCP) for fetch, filesystem, git, and web search
      context_servers = {
        fetch = {
          command = "${pkgs.mcp-server-fetch}/bin/mcp-server-fetch";
        };
        filesystem = {
          command = "${pkgs.mcp-server-filesystem}/bin/mcp-server-filesystem";
          args = [ "/home/nixidev" ];
        };
        git = {
          command = "${pkgs.mcp-server-git}/bin/mcp-server-git";
        };
        web-search = {
          command = "${pkgs.uv}/bin/uvx";
          args = [ "duckduckgo-mcp-server" ];
        };
      };
    };
  };

  # --- Zen Browser + zen-wabi Setup ---
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    profiles.default = {
      isDefault = true;
      userChrome = "${inputs.zen-wabi}/userChrome.css.template";
      userContent = "${inputs.zen-wabi}/userContent.css.template";
      settings = {
        "userChromeJS.experimental.enabled" = true;
      };
    };
  };

  # FX-Autoconfig JS bridge
  home.file.".zen/default/chrome/JS".source = "${inputs.zen-wabi}/fx-autoconfig/profile/chrome/JS";

  # --- Matugen (Zen + Zed) ---
  programs.matugen = {
    enable = true;
    templates = {
      zen-chrome = {
        input_path = "${inputs.zen-wabi}/userChrome.css.template";
        output_path = "~/.zen/default/chrome/userChrome.css";
      };
      zen-content = {
        input_path = "${inputs.zen-wabi}/userContent.css.template";
        output_path = "~/.zen/default/chrome/userContent.css";
      };
    };
  };
}
