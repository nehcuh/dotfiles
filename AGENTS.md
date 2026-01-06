# Repository Guidelines

## Project Structure & Module Organization

- `stow-packs/<package>/`: Source-of-truth dotfiles, linked into `$HOME` via GNU Stow (e.g., `stow-packs/zsh/`, `stow-packs/git/`).
- `scripts/`: Install and maintenance tooling (`install.sh`, `uninstall.sh`, `dotfile-manager.sh`, `dotfile-migrate.sh`, `manage-mirrors.sh`).
- `scripts/lib/` and `scripts/steps/`: Shared shell libraries and installer steps.
- `docs/`: Project documentation hub; start at `docs/README.md`.
- `docker-samples/`: Optional containerized environments for local testing.

## Build, Test, and Development Commands

- `make help`: List available workflows.
- `make install`: Install default packages and create symlinks (use `DOTFILES_SKIP_BREWFILE=true` to skip Brewfile; `DOTFILES_FORCE_CHINA_MIRROR=true` / `DOTFILES_FORCE_NO_MIRROR=true` to control mirror behavior).
- `make uninstall`: Remove symlinks created by this repo.
- `make update`: Pull the latest changes from the default branch.
- `make status`: Show which packages are linked and which files are managed.
- `make scan` / `make migrate` / `make auto-migrate`: Discover and migrate unmanaged dotfiles into `stow-packs/`.
- `make add FILE=~/.claude.json PACKAGE=sensitive`: Move a file into a package and re-link.
- `make clean PACKAGE=<package>`: Unlink a package (interactive confirmation).
- `./scripts/manage-mirrors.sh status|auto|china|international`: Inspect or configure package-manager mirrors.

## Coding Style & Naming Conventions

- Shell is the primary language: prefer POSIX `sh` in `scripts/lib/` and `bash` for entrypoints in `scripts/`.
- Follow existing formatting patterns (commonly 4-space indentation in `bash` scripts); keep functions small and user-facing output consistent.
- Name scripts in kebab-case (e.g., `dotfile-migrate.sh`); name packages as lower-case directories under `stow-packs/`.

## Testing Guidelines

This repo has no formal unit test suite. Validate changes by:

- Running `make status` and a Stow dry-run (`stow -nv .`) from the repo root.
- Sanity-checking scripts (`bash -n scripts/*.sh`) and running `shellcheck` when available.

## Security & Configuration Tips

- Do not commit secrets. Local-only configuration belongs in `stow-packs/sensitive/` (gitignored).
- Prefer using `./scripts/dotfile-manager.sh --move <path> sensitive` instead of manually copying sensitive files.

## Commit & Pull Request Guidelines

- Use the commit prefixes commonly found in history: `feat:`, `fix:`, `docs:`, `refactor:` (optional emoji is fine).
- PRs should include: affected packages/paths (e.g., `stow-packs/zsh/`), target OS (macOS/Linux), and a short verification note (commands run).
