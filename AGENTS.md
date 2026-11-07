# AGENTS.md — MD3E NixOS Declarative Rice

> Written for AI agents. Terse, imperative, no filler. Read the whole file before editing anything.

## 0. Agent Contract (read first)

**The user is on a very tight token budget.** Every token is expensive for them. Treat verbosity as a bug:
- Answer first, explain only if asked. No preamble, no restating the task, no "I will now…".
- Read only what you need: use `start_line`/`end_line` on big files, `grep` for symbols.
- Batch independent reads/searches into one round of tool calls.
- Never dump full logs or full file contents back to the user. Quote only the failing lines.
- Never re-read a file right after writing/editing it.
- No speculative refactors, no "while I'm here" changes.
- Keep final messages short: what changed, which files, what was validated.

**Loop guard — hard rule.**
If a command or fix fails **twice in a row** (same or similar error):
1. STOP immediately.
2. Show the failing command + the key error lines (few lines only).
3. Give your best hypothesis and at most 2 options.
4. Ask the user how to proceed.

Never attempt a third blind retry. Never cycle through variations hoping one sticks. Retry loops are a failure mode, not persistence.

**Committing:** after a successful change, commit it and bump the patch tag (`v0.5.x`) with a short message.

**Verification — minimal logging (hard rule).**

Standard verification command:
```sh
nix build --dry-run --quiet .#nixosConfigurations.nix.config.system.build.toplevel 2>&1 | tail -n 20
```

1. Always append `--quiet` to `nix build` and `nix eval`.
2. Pipe stderr to `tail -n 20` (or `head -n 20`) so only the final error lines are visible, not the whole dependency tree.
3. If a command fails, DO NOT re-run it to get more logs. Report the 20 lines you already have and ask the user to run it manually if deeper inspection is needed.

## 1. Project Intent

Fully declarative, pure NixOS config for a **MD3E (Material Design 3 Expressive)** desktop.

Absolute priority: **purity and reproducibility**.
Forbidden: imperative scripts, `--impure`, manual state edits. Everything goes through Flakes, Home Manager, or systemd.

## 2. Core Stack

| Role | Choice |
| --- | --- |
| OS | NixOS `nixos-unstable` |
| Compositor | Niri (`epireyn/niri-flake`) |
| Shell / UI | Dux Shell / DMS (`duxlabs-dev/dux-shell/stable`) |
| Theme engine | Matugen (`InioX/Matugen`) |
| Browser | Zen Browser (`0xc000022070/zen-browser-flake`) |
| Terminal | Kitty |
| Editor | Zed (`programs.zed-editor`) + Polza AI (OpenAI-compatible) |
| Shell | Zsh |

## 3. Session & Boot Architecture

- **Autologin**: patched `autologin` package on **TTY7**. TTY1 untouched (avoids Getty conflicts).
- **NVIDIA quirks**:
  - `boot.kernelParams = [ "nvidia_drm.modeset=1" "consoleblank=0" ]`
  - `environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/card1"`
- **DMS launch**: only via its systemd user service (`systemd.enable = true`).
  - **CRITICAL**: never add `spawn-at-startup = [ { command = [ "dms" "run" ]; } ];` to Niri settings → double launch, session crash.
- **Lock screen**: native, `programs.dank-material-shell.settings.lockAtStartup = true`. No custom systemd lock services.
- **TTY blanking**: handled by the `consoleblank=0` kernel parameter.

## 4. Key Files

- `flake.nix` — inputs: Nixpkgs, Home Manager, Niri, DMS, Zen Browser.
- `configuration.nix` — system level: NVIDIA, autologin, TTY7, portals, API keys, VPN.
- `home.nix` — user level: Niri settings, DMS settings, Zen theme wiring, Kitty, Zsh, Zed, packages.
- `config/zen/userChrome.css` — `@import`s the DMS-generated `~/.config/dms/zen.css`.

## 5. Strict Rules & Known Gotchas

1. **Purity**: no `--impure`. If `$HOME` access is unavoidable, use `mkOutOfStoreSymlink` or `home.activation`.
2. **Double DMS launch**: caused by systemd service + Niri `spawn-at-startup` together. Keep systemd only.
3. **Profile clobbering**: `home-manager.backupFileExtension = "backup"` + `overwriteBackup = true` prevent activation failures on browser profile collisions.
4. **Zen theming**: no zen-wabi templates, no `theme_switcher` binary. DMS/Matugen writes `~/.config/dms/zen.css`; `~/.zen/<profile>/chrome/userChrome.css` only `@import`s it (see `config/zen/userChrome.css`). Profile dir is hardcoded because nixpkgs forces `MOZ_LEGACY_PROFILES=1` (Zen uses `~/.zen`, not `~/.config/zen`).
5. **Zed AI**: configured in `home.nix` via `programs.zed-editor`, provider name `"polza"`. Never OpenRouter.
6. **TTY blanking**: `consoleblank=0` kernel param (see §3).

## 6. Current State

System is nearly fully operational. Last known good state: tag **`v0.5.5`** (post-cleanup: pipewire enabled, `POLZA_API_KEY` unified).
Test every change with `nh os switch`; roll back if it breaks the pure declarative flow.
