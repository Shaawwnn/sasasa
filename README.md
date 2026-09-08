# sasasa — personal Claude Code config

My Claude Code setup, versioned. It loads two ways, because no single mechanism carries
everything:

- **As a plugin** — `agents/`, `commands/`, `skills/` and `hooks/` load from this
  directory directly. No copying, no symlinks, no merge step.
- **By symlink** — `rules/` and `CLAUDE.md`, which plugins have no mechanism for.

## Layout

| Path | What it is | How it loads |
|---|---|---|
| `.claude-plugin/plugin.json` | Plugin manifest. `name` sets the namespace | — |
| `.claude-plugin/marketplace.json` | Lets the repo install itself as a plugin | — |
| `agents/` | 9 subagent definitions | plugin |
| `commands/` | 9 slash commands, namespaced `/sa:<name>` | plugin |
| `skills/` | 2 skills, each `<name>/SKILL.md` | plugin |
| `hooks/` | 4 hook scripts plus `hooks.json` | plugin |
| `CLAUDE.md` | Global instructions for every project | symlink to `~/.claude/CLAUDE.md` |
| `rules/` | 8 personal rules | symlink to `~/.claude/rules/` |
| `settings.json` | Theme, TUI mode, statusline, plugins | copy of `~/.claude/settings.json` |
| `examples/` | Sample config to crib from | not deployed |
| `LICENSE` | MIT | — |

## How it's wired

### The plugin half

**Try it for one session** — nothing installed, nothing written to `~/.claude`:

```sh
claude --plugin-dir ~/projects/sasasa
```

**Install it for every session** — this repo is both the plugin and its own marketplace,
so it installs from itself:

```sh
claude plugin marketplace add ~/projects/sasasa
claude plugin install sa@sasasa
```

If the install summary says `Run /reload-plugins to activate.`, run that. Check it with
`claude plugin list` and `claude plugin details sa`, which also prints the token cost.
To back out: `claude plugin uninstall sa` and `claude plugin marketplace remove sasasa`.

Validate the manifests any time with `claude plugin validate .`.

Commands and skills are namespaced by the manifest's `name`, so `/tdd` is `/sa:tdd` and
`/plan` is `/sa:plan`. Change the namespace by changing one field in
`.claude-plugin/plugin.json`.

Hook script paths use `${CLAUDE_PLUGIN_ROOT}`, which Claude Code substitutes for this
directory — so the repo can move without silently breaking them.

To load it every session instead of passing the flag, install it as a plugin.

### The symlink half

`rules/` and `CLAUDE.md` are not plugin components — plugins have no mechanism for either
— so they still need linking:

```sh
ln -s ~/projects/sasasa/CLAUDE.md ~/.claude/CLAUDE.md
ln -s ~/projects/sasasa/rules     ~/.claude/rules
```

A symlink is a signpost: `~/.claude/rules` holds nothing itself, it points here. Verify
with `ls -la ~/.claude`.

### settings.json

Not linked and not shipped by the plugin. A plugin's root `settings.json` only honours the
`agent` and `subagentStatusLine` keys and silently ignores everything else, so the theme,
TUI mode and statusline here would have no effect as plugin defaults. It stays a copy of
the live file. After changing settings through the app:
`cp ~/.claude/settings.json settings.json`.

## Maintaining it

- **Moving the repo** breaks the two symlinks silently — Claude Code sees no rules rather
  than an error. The plugin half survives, since `${CLAUDE_PLUGIN_ROOT}` is relative to
  wherever the plugin is.
- **New agent, command, skill, or rule:** add the file here. Live next session; nothing to
  relink or re-merge.
- **New skill:** must be `skills/<name>/SKILL.md`. A flat `.md` in `skills/` is never
  discovered.
- **A user-level agent overrides a plugin agent of the same name.** So don't put anything
  in `~/.claude/agents/` — it wins silently over the copy here. Skills behave the opposite
  way: both stay available under different names.
- **Health check:** `ls -la ~/.claude | grep '\->'` lists every symlink and its target -
  anything pointing at a path that no longer exists is broken. `claude plugin list`
  confirms `sa` is installed and enabled.
- **Seeing what actually loaded:** `/context` reports `CLAUDE.md` and always-on rules
  under **Memory files**, not as a separate entry. Run `/memory` for the file list, or
  `/context all` to expand. Path-scoped rules are correctly absent until Claude opens a
  matching file.

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

- `examples/` is untouched sample config from the original import.
