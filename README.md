# sasasa — personal Claude Code config

My `~/.claude` setup, versioned. Claude Code reads config from `~/.claude/`, so this repo
is **symlinked into place** — the files here are the only copies, and an edit is live in
the next session. Nothing is duplicated, nothing to re-sync.

## Layout

| Path | What it is | Linked to |
|---|---|---|
| `CLAUDE.md` | Global instructions for every project | `~/.claude/CLAUDE.md` |
| `agents/` | 9 subagent definitions | `~/.claude/agents/` |
| `commands/` | 9 slash commands | `~/.claude/commands/` |
| `skills/` | 2 skills, each `<name>/SKILL.md` | `~/.claude/skills/` |
| `rules/` | 8 personal rules | `~/.claude/rules/` |
| `settings.json` | Theme, TUI mode, statusline, plugins | copied, not linked — see below |
| `hooks/` | 4 hook scripts plus wiring | merged into `settings.json` — see below |
| `examples/` | Sample config to crib from | not deployed |

## How it's wired

Four directories and `CLAUDE.md` are symlinks. A symlink is a signpost: `~/.claude/agents`
contains nothing itself, it points at `agents/` in this repo. Claude Code follows it
without knowing.

```sh
ln -s ~/projects/sasasa/CLAUDE.md ~/.claude/CLAUDE.md
ln -s ~/projects/sasasa/agents    ~/.claude/agents
ln -s ~/projects/sasasa/commands  ~/.claude/commands
ln -s ~/projects/sasasa/skills    ~/.claude/skills
ln -s ~/projects/sasasa/rules     ~/.claude/rules
```

Verify with `ls -la ~/.claude` — each should read `agents -> /Users/sasasa/projects/sasasa/agents`.

**Two things are not symlinked:**

- **`settings.json`** — Claude Code writes to this file itself (theme, model, plugin
  toggles), so a symlink would have the app editing the repo behind git's back. It stays a
  copy. After changing settings through the app, copy the live file back:
  `cp ~/.claude/settings.json settings.json`.
- **`hooks/`** — there is no `~/.claude/hooks/` directory. The `hooks` key from
  `hooks/hooks.json` has to be merged into `~/.claude/settings.json` by hand. The scripts
  themselves stay put, since `hooks.json` references them by absolute path.

## Maintaining it

- **Renaming or moving this repo breaks everything, silently.** Symlinks become dangling
  and Claude Code sees no agents rather than an error. `hooks.json` hard-codes
  `/Users/sasasa/projects/sasasa/hooks/scripts/` too. If the repo moves, relink and update
  those paths.
- **New agent, command, or rule:** add the file here. It's live immediately — no relinking,
  the directory itself is the link.
- **New skill:** must be `skills/<name>/SKILL.md`. A flat `.md` in `skills/` is never
  discovered.
- **Editing a hook script:** live immediately. Editing `hooks/hooks.json` requires
  re-merging into `~/.claude/settings.json`.
- **Health check:** `ls -la ~/.claude` for dangling links, and
  `jq -r '.hooks[][].hooks[].args[0]' hooks/hooks.json | xargs ls -l` to confirm every hook
  script still resolves.

## State

Everything has been through a pass: examples and another project's domain content removed,
tooling made conditional rather than assumed, and duplication collapsed so each procedure
lives in one place.

| | lines |
|---|---|
| `agents/` | 1129 — portable; each detects the project's tooling instead of assuming it |
| `rules/` | 370 — 188 always-on, the rest scoped by `paths:` frontmatter |
| `hooks/` | 4 scripts, heavily commented, each testable standalone |
| `commands/` | 72 — thin; each delegates to its agent rather than restating the procedure |
| `skills/` | 93 — two pattern checklists |

Agents own the procedures. Commands are entry points to agents. Rules are always-on or
file-scoped preferences. Skills are on-demand reference. One copy of anything.

Model assignment: `opus` for reasoning (architect, planner, both reviewers), `sonnet` for
mechanical work (build, docs, e2e, refactor, tdd).

`/sa-code-review` is named to avoid shadowing the bundled `/code-review`; a personal
command of the same name would replace the built-in and hide its `--comment` and `--fix`
options.

## Still open

- Hooks are not merged into `~/.claude/settings.json`, so they aren't running.
- `examples/` is untouched sample config from the original import.
