# AGENTS.md - MD3E NixOS Rice (Pure & Declarative)

## Project Intent
Fully declarative, pure NixOS configuration for an **MD3E** desktop. Purity and reproducibility are absolute. No imperative scripts or `--impure` flags.

## Core Stack
- **OS**: NixOS unstable
- **Compositor**: Niri
- **Shell/UI**: Dux Shell / DMS
- **Theme Engine**: Matugen
- **Browser**: Zen Browser (zen-wabi)
- **Terminal**: Kitty
- **Editor**: VS Code (Cline + DMS Theme + Matugen)
- **Shell**: Zsh

## Session & Boot
- **Autologin**: Patched `autologin` on TTY7.
- **NVIDIA**: `nvidia_drm.modeset=1`, `consoleblank=0`, `WLR_DRM_DEVICES="/dev/dri/card1"`.
- **DMS Launch**: Systemd user service only. **NEVER** add `spawn-at-startup` for DMS.
- **Lock Screen**: DMS `lockAtStartup = true`.

## Theming
- Matugen generates `userChrome.css` / `userContent.css` for Zen.
- Matugen generates a VS Code theme JSON for the DMS extension.
- Cline is configured with `POLZA_AI_API_KEY` and `POLZA_BASE_URL` (OpenAI compatible).

## Rules
- Do NOT use `--impure`.
- Do NOT compile `theme_switcher` for zen-wabi.
- Stick to systemd for DMS.
