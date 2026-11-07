# AGENTS.md - MD3E NixOS Declarative Rice

## Project Intent
This repository is a fully declarative, pure NixOS configuration for an **MD3E (Material Design 3 Expressive)** desktop environment. The absolute priority is **purity and reproducibility**. Imperative scripts, `--impure` flags, and manual state modifications are strictly forbidden. Everything must be managed via Flakes, Home Manager, or systemd.

## Core Stack
- **OS**: NixOS unstable (`nixos-unstable`)
- **Compositor**: Niri (via `epireyn/niri-flake`)
- **Shell/UI**: Dux Shell / DMS (via `duxlabs-dev/dux-shell/stable`)
- **Theme Engine**: Matugen (via `InioX/Matugen`)
- **Browser**: Zen Browser (via `0xc000022070/zen-browser-flake`).
- **Terminal**: Kitty
- **Editor**: Zed (`programs.zed-editor`) with Polza AI (OpenAI-compatible).
- **Shell**: Zsh

## Session & Boot Architecture
- **Autologin**: Uses a patched `autologin` package on **TTY7**. TTY1 is left alone to avoid Getty conflicts. 
- **NVIDIA Quirks**: 
  - `boot.kernelParams = [ "nvidia_drm.modeset=1" "consoleblank=0" ]`
  - `environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/card1"`
- **DMS Launch**: DMS is managed entirely by its systemd user service (`systemd.enable = true`). 
  - **CRITICAL**: Never add `spawn-at-startup = [ { command = [ "dms" "run" ]; } ];` to Niri settings. It causes a double launch and crashes the session.
- **Lock Screen**: Handled natively via `programs.dank-material-shell.settings.lockAtStartup = true`. No custom systemd lock services are needed.

## Key Files
- `flake.nix`: Inputs for Nixpkgs, Home Manager, Niri, DMS, and Zen Browser.
- `configuration.nix`: System-level config (NVIDIA, Autologin, TTY7, Portals, API Keys, VPN).
- `home.nix`: User-level config (Niri settings, DMS settings, Zen Browser theme wiring, Kitty, Zsh, Zed, Packages).
- `config/zen/userChrome.css`: `@import`s the DMS-generated `~/.config/dms/zen.css`.

## Strict Rules & Known Gotchas
1. **Purity**: Do NOT use `nix` commands with `--impure`. Use `mkOutOfStoreSymlink` or `home.activation` if reading from `$HOME` is unavoidable.
2. **Double DMS Launch**: Caused by having both the systemd service and a Niri `spawn-at-startup` command. Stick to systemd.
3. **Profile Clobbering**: `home-manager.backupFileExtension = "backup"` and `overwriteBackup = true` prevent activation failures on browser profile collisions.
4. **Zen Theming**: Do NOT use zen-wabi templates or compile a `theme_switcher` binary. DMS/Matugen writes `~/.config/dms/zen.css`; `~/.zen/<profile>/chrome/userChrome.css` just `@import`s it (see `config/zen/userChrome.css`). The profile dir is hardcoded because nixpkgs forces `MOZ_LEGACY_PROFILES=1` (Zen uses `~/.zen`, not `~/.config/zen`).
5. **Zed AI**: Configured via `programs.zed-editor` in `home.nix`. Uses provider name `"polza"`. Do not use OpenRouter.
6. **TTY Blanking**: Handled via the `consoleblank=0` kernel parameter.

## Current State
The system is almost fully operational and committed. The last known good state is tagged `v0.5.1`. All subsequent modifications should be tested with `nh os switch` and rolled back if they break the pure declarative flow.
