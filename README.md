# sasasa — personal Claude Code config

My `~/.claude` setup, versioned. Seeded from a fork of
[`affaan-m/ECC`](https://github.com/affaan-m/ECC) (via `Shaawwnn/everything-claude-code`,
pinned at `3c1e7d99`), plus my own `CLAUDE.md` and `settings.json`.

**Status: unpruned import.** Everything came across as-is so it could be triaged in
place. Most of it is written for someone else's stack and should not be deployed
to `~/.claude` until it has been reviewed. See the triage list below.

## Layout

| Path | What it is | Deploys to |
|---|---|---|
| `CLAUDE.md` | Global instructions for every project | `~/.claude/CLAUDE.md` |
| `settings.json` | Theme, TUI mode, statusline, enabled plugins | `~/.claude/settings.json` |
| `agents/` | 9 subagent definitions | `~/.claude/agents/` |
| `commands/` | 9 slash commands | `~/.claude/commands/` |
| `skills/` | 6 skills (2 as `SKILL.md` dirs) | `~/.claude/skills/` |
| `rules/` | 8 rule docs, referenced from `CLAUDE.md` | project-level, by reference |
| `hooks/hooks.json` | PreToolUse/PostToolUse hooks | merge into `settings.json` |
| `mcp-configs/` | 15 MCP server definitions | `~/.claude.json` or per-project |
| `examples/` | Upstream's sample `CLAUDE.md` / statusline | reference only |

## Triage

Reviewed against my actual stack (GCP, Terraform, Firebase, Next.js, TypeScript).

### Deploy as-is — stack-agnostic
- `agents/`: architect, planner, code-reviewer, security-reviewer, refactor-cleaner,
  build-error-resolver, doc-updater
- `commands/`: plan, code-review, refactor-clean, build-fix, update-docs, test-coverage
- `skills/`: coding-standards, security-review, tdd-workflow

### Rewrite for my stack
- `skills/frontend-patterns.md`, `skills/backend-patterns.md` — assume a different stack
- `rules/` — opinionated defaults; keep the shape, replace the specifics
- `agents/tdd-guide.md`, `agents/e2e-runner.md`, `commands/tdd.md`, `commands/e2e.md`
  — tied to a test setup I don't run yet

### Cut
- `skills/clickhouse-io.md` — I don't use ClickHouse
- `skills/project-guidelines-example.md` — a placeholder
- `mcp-configs/`: clickhouse, cloudflare-\* (4), supabase, railway, vercel, firecrawl,
  magic — wrong cloud. Keep: github, filesystem, context7, memory, sequential-thinking
- `commands/update-codemaps.md` — depends on a codemap convention I don't have
- `plugins/README.md` — upstream docs, not config

### Do not deploy without editing — `hooks/hooks.json`
These are aggressive and will disrupt normal work:
1. **Blocks all dev servers** not launched inside tmux — hard `exit 1`
2. **Blocks writing any `.md`/`.txt`** except README/CLAUDE/AGENTS/CONTRIBUTING — hard `exit 1`
3. **Pauses every `git push`** on a blocking `read -r`, which hangs a non-interactive session

Hook 3 in particular will hang any automated or agent-driven push. Treat this file as a
menu to pick from, not a config to install.

## Deploying

Nothing here is symlinked into `~/.claude` yet — the repo is currently a staging area.
Decide on a deploy method (symlink, copy script, or GNU stow) once the triage is done.
