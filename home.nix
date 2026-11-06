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

  # Packages
  home.packages = with pkgs; [
    htop git nix-output-monitor nvd wl-clipboard cliphist pamixer wireplumber
    eza ripgrep fastfetch bat fzf btop vscodium bash nixos-icons python3
  ];

  # XDG Links
  xdg.configFile."kitty/kitty.conf".source = ./config/kitty/kitty.conf;
  xdg.configFile."fastfetch/config.jsonc".source = ./config/fastfetch/config.jsonc;
  xdg.configFile."btop/btop.conf".source = ./config/btop/btop.conf;
  xdg.configFile."bat/config".source = ./config/bat/config;
    xdg.configFile."micro/settings.json".source = ./config/micro/settings.json;

  gtk.enable = true;

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
      code = "codium";
    };
  };

  programs.starship = { enable = true; enableZshIntegration = true; };
  programs.home-manager.enable = true;
  programs.zoxide.enable = true;
  programs.fzf.enable = true;

  # Niri Settings
  programs.niri.settings = {
    layout.border.enable = false;
    prefer-no-csd = true;
    hotkey-overlay.skip-at-startup = true;
    input = {
      focus-follows-mouse.enable = true;
      warp-mouse-to-focus.enable = true;
    };
  };
  
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
        "alttab" "binds-next" "binds" "colors" "cursor"
        "layout" "outputs" "windowrules" "wpblur"
      ];
    };
  };

  # --- VS Code + Cline (AI) Setup ---
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        saoudrizwan.claude-dev       # Cline (Agentic AI)
        continue.continue            # Continue (Fallback AI autocomplete)
      ];
      userSettings = {
        # Cline configuration for Polza AI (OpenAI Compatible)
        "cline.apiProvider" = "openai";
        "cline.apiKey" = "\${env:POLZA_AI_API_KEY}";
        "cline.apiBaseUrl" = "\${env:POLZA_BASE_URL}";
        "cline.model" = "anthropic/claude-3.5-sonnet"; # Or whatever Polza model you prefer
        
        # UI settings
        "workbench.colorTheme" = "DMS - Dank Material Shell";
        "window.titleBarStyle" = "native";
        "editor.fontFamily" = "Fira Code";
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
      settings."userChromeJS.experimental.enabled" = true;
    };
  };

  home.file.".zen/default/chrome/JS".source = "${inputs.zen-wabi}/fx-autoconfig/profile/chrome/JS";

  # --- Matugen (Zen + VS Code) ---
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
      # Generate a VS Code theme JSON for the DMS extension
      vscode-theme = {
        input_path = pkgs.writeText "vscode-theme.json" ''
          {
            "name": "DMS - Dank Material Shell",
            "type": "dark",
            "colors": {
              "editor.background": "{{colors.surface.default.hex}}",
              "editor.foreground": "{{colors.on_surface.default.hex}}",
              "sideBar.background": "{{colors.surface_container_low.default.hex}}",
              "activityBar.background": "{{colors.surface_container.default.hex}}",
              "statusBar.background": "{{colors.primary.default.hex}}",
              "statusBar.foreground": "{{colors.on_primary.default.hex}}"
            }
          }
        '';
        output_path = "~/.cache/matugen/vscode-colors.json";
      };
    };
  };
}
