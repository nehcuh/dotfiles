# Folding + Strict Allowlist Design

**Goal:** Keep using GNU Stow folding (directory symlink style) for convenience, while ensuring Git only tracks stable configuration files and never accidentally tracks runtime/cached data produced inside folded directories.

## Principles

- **Folding stays on:** Packages may link directories as symlinks into the repo.
- **Git tracking is strict allowlist:** Only files declared in a manifest are allowed to be tracked by Git.
- **Runtime artifacts are expected:** Apps may create extra files/directories under folded paths; these must be ignored by default.
- **Verification is automated:** A validator script checks that tracked files ⊆ manifest, and that manifest entries resolve to exactly one package path.

## Data Model

- Manifest: `docs/managed-files.yml`
  - `tracked:` list of `{package, path}` where `path` is `$HOME`-relative (stable config intended to be tracked).
  - `untracked:` list of `{package, path}` for managed-but-not-tracked items (typically sensitive).

## Git Strategy (Allowlist-by-default)

- For directories prone to runtime output (e.g. Zed), add a `.gitignore` in the corresponding directory:
  - ignore everything by default
  - re-allow only stable files (and `.gitignore`) via negation patterns
  - this prevents new runtime output from ever showing up as git changes

## Tooling

- `scripts/validate-managed-files.sh`
  - Validates that every `tracked:` entry exists exactly once under `stow-packs/*/<path>`.
  - Validates that every git-tracked file under `stow-packs/` is included in `tracked:`.
  - Reports (or optionally errors) on manifest entries that do not currently exist.

## Status Reporting

- `scripts/status.sh` should prefer the manifest as the “stable file list” to avoid counting runtime output as managed configuration.
