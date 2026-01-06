# Dotfiles Install & Migration Optimization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 让本仓库在“用 GNU Stow 统一管理稳定配置文件（非缓存）”这一目标上可重复、可验证地达成，并让 `scan/migrate/status` 的输出可信。

**Architecture:** `stow-packs/` 作为单一事实来源；迁移工具只“收拢稳定配置”并保持 `$HOME` 相对路径；状态检查基于真实 symlink 目标而非 Stow 可安装性；安装链路保持“默认无副作用、需要显式 opt-in 才会覆盖/变更系统状态”。

**Tech Stack:** Bash, GNU Stow, Makefile, Docker（可选：Linux devbox 集成检查）

---

## Scope / Non-goals

- **In scope:** 修复迁移工具误扫/错分/丢路径；修复 `dotfile-manager` 迁移嵌套路径（如 `~/.ssh/config`）；修复 `make status` 误报；校准 Starship 初始化顺序；清理默认安装包列表的缺失项；补充最小可运行的本地集成测试。
- **Out of scope:** 迁移/管理缓存类目录（如 `~/.cache`、`~/.npm`、`~/.config/configstore` 等）；自动迁移密钥/凭证本体（仅建议迁移配置文件，例如 `~/.ssh/config`）。

## Acceptance Criteria

- `./scripts/dotfile-migrate.sh scan` **不再**建议迁移 `~/.config` 根目录。
- `./scripts/dotfile-migrate.sh scan` 分类符合包语义：`.config/nvim`→`nvim`，`.config/Code`→`vscode`，`.config/zed`→`zed`（或按最终约定）。
- `./scripts/dotfile-migrate.sh migrate|auto` 迁移后 **保留原始相对路径**（例如 `~/.ssh/config`→`stow-packs/sensitive/.ssh/config`）。
- `./scripts/dotfile-manager.sh --move ~/.ssh/config sensitive` 能正确迁移并生成 `~/.ssh/config` 的 symlink（不丢 `.ssh/` 层级）。
- `make status` 输出“已链接/未链接”不再系统性误报；能反映真实管理情况。
- 默认安装不再出现“Package vim not found, skipping”这类缺失包噪音（要么移除默认包，要么补齐包）。
- Starship：未安装时不报错；已安装时配置不被后续脚本覆盖（`~/.config/starship.toml` 生效）。

---

### Task 1: Add Migration/Manager Integration Test Script

**Files:**
- Create: `scripts/test-migration.sh`

**Step 1: Write failing checks (initial baseline)**

在 `scripts/test-migration.sh` 中加入这些断言（基于当前已知问题应当失败）：
- `scan` 输出包含 `.config`（应当被修复为不包含）
- `dotfile-manager --move ~/.ssh/config` 迁移后目标路径不包含 `.ssh/`（应当被修复）

**Step 2: Run to confirm failures**

Run: `bash scripts/test-migration.sh`
Expected: FAIL（提示上述断言未满足）

**Step 3: Keep harness minimal & hermetic**

让测试在临时目录中复制一份仓库再运行（避免污染真实工作区/真实 `$HOME`）：
- `TMP_REPO=$(mktemp -d)`，用 `tar` 复制仓库（排除 `.git`、排除 `stow-packs/sensitive`）
- `HOME=$(mktemp -d)`，在临时 HOME 构造示例文件结构

**Step 4: Re-run after each fix**

Run: `bash scripts/test-migration.sh`
Expected: 逐步从 FAIL 变为 PASS

**Step 5: Commit**

Commit: `test: add migration integration checks`

---

### Task 2: Fix `dotfile-migrate.sh` Scanning Rules

**Files:**
- Modify: `scripts/dotfile-migrate.sh`
- Test: `scripts/test-migration.sh`

**Step 1: Write a failing test for “skip ~/.config root”**

在测试里构造：
- `$HOME/.config/` 存在且为目录
- `$HOME/.config/gh/` 等子目录存在

断言：`scan` 输出中 **不包含** 独立项 `.config`，但包含 `.config/gh/` 等子项。

**Step 2: Implement minimal fix**

在扫描主目录的循环中显式跳过 `.config` 本体（以及其它不应迁移的目录）：
- 在 `scan_dotfiles()` / `interactive_migrate()` 的 `$HOME/.[!.]*` 循环里，`case "$(basename "$file")" in .config) continue ;; esac`

**Step 3: Add “known nested files” scan**

补充扫描若干稳定的“嵌套文件”而不是目录：
- `~/.ssh/config`
- `~/.gitconfig_local`
- `~/.zshrc.local`

实现方式：新增 `KNOWN_NESTED_FILES=(...)`，逐个检查存在且未管理则加入候选列表。

**Step 4: Run tests**

Run: `bash scripts/test-migration.sh`
Expected: PASS（至少 “skip ~/.config root” 断言通过）

**Step 5: Commit**

Commit: `fix: migration scan rules`

---

### Task 3: Make Category Resolution Deterministic & Package-aligned

**Files:**
- Modify: `scripts/dotfile-migrate.sh`
- Test: `scripts/test-migration.sh`
- (Optional) Docs: `docs/guides/MIGRATION_GUIDE.md`

**Step 1: Add failing tests for misclassification**

在临时 HOME 构造：
- `$HOME/.config/nvim/`
- `$HOME/.config/zed/`
- `$HOME/.config/Code/`

断言：`scan` 输出的“类型”分别为 `nvim` / `zed` / `vscode`（或按最终决定）。

**Step 2: Implement category precedence**

把 `get_category()` 调整为“先匹配更具体的包，再匹配通用包”，避免重复条目被前置数组吞掉：
- 优先：`nvim`、`vscode`、`zed`、`tmux`
- 其次：`git`、`system`
- 再次：`tools`、`personal`
- 最后：`sensitive` 作为默认兜底（安全优先）

推荐做法：用 `case "$relative_path" in ... esac` 统一表达，减少多个数组重复维护。

**Step 3: Ensure category has a corresponding stow package**

在 `migrate_file()` 前做一次校验：
- 若 `stow-packs/$category` 不存在，则提示并回退到 `sensitive` 或中止（按你更偏好的策略）。

**Step 4: Run tests**

Run: `bash scripts/test-migration.sh`
Expected: PASS（分类断言通过）

**Step 5: Commit**

Commit: `refactor: deterministic migration categorization`

---

### Task 4: Fix `dotfile-manager.sh --move` to Preserve Relative Paths

**Files:**
- Modify: `scripts/dotfile-manager.sh`
- Test: `scripts/test-migration.sh`

**Step 1: Add failing test for `~/.ssh/config` path preservation**

构造：`$HOME/.ssh/config` 为普通文件。

断言：
- 迁移后存在：`$REPO/stow-packs/sensitive/.ssh/config`
- 且 `$HOME/.ssh/config` 为 symlink，目标指向上述路径（相对/绝对都可，只要落在 repo 内）

**Step 2: Implement minimal path-preserving move**

替换当前基于 `basename/dirname` 的目标路径推导：
- `relative_path="${source_file#$HOME/}"`
- `target_path="$DOTFILES_DIR/stow-packs/$target_package/$relative_path"`
- `mkdir -p "$(dirname "$target_path")"`
- `mv "$source_file" "$target_path"`

**Step 3: Use Stow consistently**

将 `stow` 调用统一为：
- `stow -d stow-packs -t "$HOME" -R "$target_package"`

失败时输出可操作建议（例如提示用户先解决冲突/安装 stow），避免“手动 ln -sf”生成不一致的链接结构。

**Step 4: Run tests**

Run: `bash scripts/test-migration.sh`
Expected: PASS（`.ssh/config` 迁移断言通过）

**Step 5: Commit**

Commit: `fix: dotfile-manager preserves nested paths`

---

### Task 5: Fix `make status` to Reflect Reality

**Files:**
- Modify: `Makefile`
- (Optional) Create: `scripts/status.sh`
- Test: `bash -n Makefile`（或直接 `make status`）

**Step 1: Write failing scenario**

在真实环境或临时 HOME（测试脚本里）安装若干包后，`make status` 仍显示全部 “not linked”（现状）。

**Step 2: Implement status logic**

选项 A（更稳）：新增 `scripts/status.sh`，按包遍历其文件列表，检查 `$HOME/<path>` 是否为 symlink 且目标落在 `.dotfiles/stow-packs/<pkg>/...`，给出：
- `linked (all)` / `linked (partial)` / `not linked`

选项 B（更省）：修正 Makefile 中 `stow` 的 `-d/-t` 参数错误，但要避免把“可安装”误判成“已安装”。

**Step 3: Verify**

Run: `make status`
Expected: 能反映真实状态，不再全量误报

**Step 4: Commit**

Commit: `fix: status reporting`

---

### Task 6: Clean Up Default Package List & Starship Init Order

**Files:**
- Modify: `scripts/steps/packages.sh`
- Modify: `stow-packs/zsh/.zshrc`
- Test: `scripts/test-linux-install.sh`（可选）, `bash scripts/test-migration.sh`

**Step 1: Default packages sanity**

决定策略：
- 若不提供 `stow-packs/vim/`，则从默认包列表移除 `"vim"`；或新增最小 `stow-packs/vim/.vimrc`。

**Step 2: Starship robustness**

在 `stow-packs/zsh/.zshrc`：
- `command -v starship >/dev/null && eval "$(starship init zsh)"`
- 将该行移动到模块加载之后（避免被后续 prompt 覆盖）

**Step 3: Verify**

Run: `zsh -lc 'source ~/.zshrc; echo ok'`
Expected: 未安装 starship 时无报错；安装后提示符生效（人工确认）

**Step 4: Commit**

Commit: `fix: default packages and starship init`

---

## Final Verification Checklist (before merge)

- `bash -n scripts/*.sh`
- `bash scripts/test-migration.sh`
- (Optional, Linux) `bash scripts/test-linux-install.sh --strict`
- `make status`

---

## Execution Handoff

Plan complete and saved to `docs/plans/2026-01-06-dotfiles-optimization.md`. Two execution options:

1. Subagent-Driven (this session) — REQUIRED SUB-SKILL: use superpowers:subagent-driven-development  
2. Parallel Session (separate) — REQUIRED SUB-SKILL: open new session with superpowers:executing-plans

Which approach?

