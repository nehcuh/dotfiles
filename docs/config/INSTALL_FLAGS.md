# Installation Flags (Environment Variables)

This repo’s installer is driven by environment variables.

## Core Behavior

- `DOTFILES_NON_INTERACTIVE=true|false`  
  Skip interactive prompts.

- `DOTFILES_CONFLICT_OVERWRITE=true|false`  
  When a target path already exists (and is not a symlink), installer aborts by default. Set this to `true` to back up conflicting regular files and overwrite.  

## Brewfile (macOS)

- `DOTFILES_SKIP_BREWFILE=true|false`  
  Skip `brew bundle` entirely.

- `DOTFILES_BREWFILE_INSTALL=true|false`  
  Allow Brewfile install even without a TTY (non-interactive). Default is `false`.  

## Default Shell

- `DOTFILES_SET_DEFAULT_SHELL=true|false`  
  Allow the installer to run `chsh -s $(command -v zsh)` to change login shell. Default is `false`.  

## Mirrors & Network

- `DOTFILES_SKIP_MIRROR_DETECT=1`  
  Skip mirror auto-detection (useful when offline or behind restricted networks).

- `DOTFILES_FORCE_CHINA_MIRROR=true|false`  
  Force China mirror mode.

- `DOTFILES_FORCE_NO_MIRROR=true|false`  
  Force international/official sources.

## Homebrew Options (China)

- `DOTFILES_HOMEBREW_USE_CHINA_INSTALLER=true|false`  
  Opt-in to a third-party China Homebrew installer script (higher supply-chain risk). Default is `false`.  

- `DOTFILES_HOMEBREW_TAP_CHINA_MIRRORS=true|false`  
  Opt-in to switching Homebrew tap remotes (e.g. `homebrew/core`) to China mirrors (rewrites local brew config). Default is `false`.  
