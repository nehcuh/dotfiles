# Generated target summary

- Target: `claude-code`
- Profile: `claude-code-default`
- Profile maturity: `active`
- Generated at: `2026-03-27T06:24:44Z`
- Applied overlay: `none`

## Capability mapping

- `critical_reasoner` → `claude.opus-class`
- `workhorse_coder` → `claude.sonnet-class`
- `fast_router` → `claude.haiku-class`
- `independent_verifier` → `second-model.cross-family`
- `cheap_local` → `local.ollama-class`

## Overlay

- none

## Behavior policies

- `ssot-first` (`mandatory`) — Keep repository files as the single source of truth; tool-managed memory is cache.
- `verify-before-claim` (`mandatory`) — Never claim completion without fresh verification evidence.
- `capability-tier-routing` (`mandatory`) — Route by capability tier first, then resolve through the active provider profile.
- `reversible-small-batches` (`recommended`) — Prefer small, reversible, single-purpose changes over large mixed batches.
- `root-cause-debugging` (`mandatory`) — Investigate root cause before attempting fixes and reassess after repeated failures.
- `security-escalation` (`mandatory`) — Treat destructive commands, network egress, secret access, and obfuscation as security-sensitive actions.
- `record-reusable-learning` (`recommended`) — Record user corrections, repeated failures, and counter-intuitive discoveries for reuse.
- `sunday-rule` (`recommended`) — Batch workflow or system optimization separately from delivery work unless it blocks production.

## Skills

- `systematic-debugging` (`P0`, `mandatory`) — Find root cause before attempting fixes.
- `verification-before-completion` (`P0`, `mandatory`) — Require fresh verification evidence before claiming completion.
- `session-end` (`P0`, `mandatory`) — Capture handoff, memory, and wrap-up state before ending a session.
- `planning-with-files` (`P1`, `suggest`) — Use persistent files as working memory for complex multi-step tasks.
- `experience-evolution` (`P1`, `suggest`) — Capture reusable lessons and patterns from repeated work.
- `instinct-learning` (`P1`, `suggest`) — Automatic pattern extraction from sessions with confidence scoring.
- `gstack/office-hours` (`P2`, `suggest`) — Product brainstorming with forcing questions — reframes problems before code is written.
- `gstack/plan-ceo-review` (`P2`, `suggest`) — CEO/founder perspective review — find the 10-star product hiding in the request.
- `gstack/plan-eng-review` (`P2`, `suggest`) — Engineering architecture review with diagrams, edge cases, and test plans.
- `gstack/plan-design-review` (`P2`, `manual`) — Design review with 0-10 ratings per dimension and AI slop detection.
- `gstack/design-consultation` (`P2`, `manual`) — Build a complete design system — research landscape, propose creative risks, generate mockups.
- `gstack/review` (`P2`, `suggest`) — Pre-landing PR review — SQL safety, LLM trust boundaries, structural issues, auto-fixes.
- `gstack/design-review` (`P2`, `manual`) — Visual design audit with fixes — audits implemented design and applies changes.
- `gstack/codex` (`P2`, `manual`) — Cross-model second opinion via OpenAI Codex CLI — independent review from a different AI.
- `gstack/investigate` (`P2`, `suggest`) — Systematic root-cause debugging with auto-freeze scope boundary.
- `gstack/qa` (`P2`, `suggest`) — Browser QA — test app in real Chromium, find bugs, fix with atomic commits, generate regression tests.
- `gstack/qa-only` (`P2`, `manual`) — QA reporting without code changes — pure bug report from browser testing.
- `gstack/browse` (`P2`, `manual`) — Headless Chromium browser — navigate, click, screenshot, assert element states.
- `gstack/setup-browser-cookies` (`P2`, `manual`) — Import cookies from real browser (Chrome, Arc, Brave, Edge) into headless session.
- `gstack/ship` (`P2`, `suggest`) — Release workflow — sync main, run tests, audit coverage, push, open PR.
- `gstack/document-release` (`P2`, `suggest`) — Auto-update all project docs to match what was just shipped.
- `gstack/retro` (`P2`, `manual`) — Team-aware weekly retrospective with per-person breakdowns and shipping streaks.
- `gstack/careful` (`P2`, `suggest`) — Safety guardrails — warns before destructive commands.
- `gstack/freeze` (`P2`, `manual`) — Edit scope lock — restrict file edits to one directory during debugging.
- `gstack/guard` (`P2`, `manual`) — Maximum safety — careful + freeze combined.
- `gstack/unfreeze` (`P2`, `manual`) — Remove edit scope lock set by /freeze.
- `riper-workflow` (`P1`, `suggest`) — Structured 5-phase development workflow (Research, Innovate, Plan, Execute, Review).
- `using-git-worktrees` (`P1`, `suggest`) — Branch isolation using git worktrees for parallel task execution.
- `skill-craft` (`P2`, `suggest`) — Automatically detect recurring patterns and generate reusable skills.
