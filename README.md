# sasasa — personal Claude Code config

My `~/.claude` setup, versioned: the agents, commands, skills, rules and hooks I want
available in every project.

Nothing here is deployed yet. The repo is a staging area until each piece has been
reviewed and tailored — see [Status](#status).

## Layout

| Path | What it is | Deploys to |
|---|---|---|
| `CLAUDE.md` | Global instructions for every project | `~/.claude/CLAUDE.md` |
| `settings.json` | Theme, TUI mode, statusline, enabled plugins | `~/.claude/settings.json` |
| `agents/` | Subagent definitions | `~/.claude/agents/` |
| `commands/` | Slash commands | `~/.claude/commands/` |
| `skills/` | Skills — flat `.md`, or a directory with `SKILL.md` | `~/.claude/skills/` |
| `rules/` | Personal rules; `paths:` frontmatter scopes them to matching files | `~/.claude/rules/` |
| `hooks/` | Hook scripts plus their wiring — see `hooks/README.md` | merge into `settings.json` |
| `examples/` | Sample `CLAUDE.md` and statusline to crib from | reference only |

## Status

**Hooks — done.** Four working hooks, each a commented script in `hooks/scripts/`, wired
by absolute path from `hooks/hooks.json`. Written to be readable: the comments explain the
bash as much as the logic. Not merged into `settings.json` yet.

**Rules — done.** Eight files, four scoped with `paths:` frontmatter so they load only
when Claude opens a matching file. 188 lines load every session instead of 378. Stale
facts corrected: the model lineup, the hook inventory, `permissions.allow` (not
`allowedTools`), and `TaskCreate`/`TaskUpdate` (not `TodoWrite`).

**Everything else — raw.** The rest arrived as a bulk import and is still generic or aimed
at the wrong stack. My actual stack is GCP, Terraform, Firebase, Next.js and TypeScript.

### To do

Keep as-is — stack-agnostic and useful:
- `agents/`: architect, planner, code-reviewer, security-reviewer, refactor-cleaner,
  build-error-resolver, doc-updater
- `commands/`: plan, code-review, refactor-clean, build-fix, update-docs, test-coverage
- `skills/`: coding-standards, security-review, tdd-workflow

Rewrite for my stack:
- `skills/frontend-patterns.md`, `skills/backend-patterns.md`
- `agents/tdd-guide.md`, `agents/e2e-runner.md`, `commands/tdd.md`, `commands/e2e.md` —
  tied to a test setup I don't run yet

Cut:
- `skills/clickhouse-io.md`, `skills/project-guidelines-example.md`
- `commands/update-codemaps.md` — depends on a codemap convention I don't have

## Deploying

Nothing is symlinked into `~/.claude`. Pick a method — symlink, a copy script, or GNU
stow — once the list above is worked through.
