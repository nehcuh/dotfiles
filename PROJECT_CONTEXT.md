# Project Context

> dotfiles — Personal system configuration managed with GNU Stow.

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `make install` | Run full installation |
| `make stow` | Stow all packages |
| `./scripts/manage-mirrors.sh auto` | Configure China mirrors |

---

## Session Handoff

<!-- handoff:start -->
### 2026-03-27 15:30

**Last session**: Fixed Homebrew branch references (master → main)

**Changes committed**:
- `stow-packs/zsh/.config/zsh/aliases.zsh` — upgrade_repo now uses `origin main`
- `scripts/lib/china-mirror.sh` — gitee installer uses `HEAD` instead of `master`
- Synced Claude Code config (`.vibe/`, `CLAUDE.md`)
- Removed VS Code and Zed editor configs (deprecated)

**Current state**: Clean working tree, all changes pushed to origin/main.

**Next**: None pending.
<!-- handoff:end -->

---

## Structure

```
├── stow-packs/
│   ├── editor/        # Editor configs (selectively versioned)
│   ├── git/           # Git configuration
│   ├── mirrors-*/     # Package manager mirrors (china/intl)
│   ├── personal/      # Personal preferences (safe to commit)
│   ├── sensitive/     # Secrets (NEVER commit)
│   ├── system/        # System-level configs (Brewfile)
│   ├── tools/         # Dev tools (cargo, docker, etc)
│   └── zsh/           # Shell configuration
├── scripts/
│   ├── install.sh     # Main installer
│   ├── lib/           # Shared functions
│   └── manage-mirrors.sh
└── Makefile
```

---
