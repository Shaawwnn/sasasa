# sasasa — personal Claude Code config

My Claude Code setup, versioned. It loads two ways, because no single mechanism carries
everything:

- **As a plugin** — `agents/`, `commands/`, `skills/` and `hooks/` load from this
  directory directly. No copying, no symlinks, no merge step.
- **By symlink** — `rules/` and `CLAUDE.md`, which plugins have no mechanism for.

## Using this yourself

You don't have to take all of it. The plugin and the symlinks are independent — install
one, both, or neither.

### 1. Install the plugin (agents, commands, skills, hooks)

```sh
claude plugin marketplace add Shaawwnn/sasasa
claude plugin install sa@sasasa
```

If the install summary says `Run /reload-plugins to activate.`, run that.

Check it worked:

```sh
claude plugin list              # sa@sasasa, enabled
claude plugin details sa        # inventory and token cost
```

Commands are namespaced by the plugin name, so they're `/sa:plan`, `/sa:tdd`,
`/sa:build-fix` and so on — type `/sa:` and autocomplete will list them.

**What turns on immediately:** four hooks run in every project. Prettier formats JS/TS
files you edit (only if Prettier is already installed - it never downloads anything), a
note appears when an edited file still contains `console.log`, and the same check runs
again at the end of each turn. None of them block; all stay silent when there's nothing
to say. Read `hooks/README.md` before enabling if you'd rather know exactly what runs.

To remove it all:

```sh
claude plugin uninstall sa
claude plugin marketplace remove sasasa
```

### 2. Take the rules and CLAUDE.md (optional, separate)

Plugins can't carry either of these, so they're symlinked by hand. **These are personal
preferences, not general advice** — read them before linking, and copy the files instead
if you want to edit them.

```sh
git clone https://github.com/Shaawwnn/sasasa.git
ln -s /absolute/path/to/sasasa/CLAUDE.md ~/.claude/CLAUDE.md
ln -s /absolute/path/to/sasasa/rules     ~/.claude/rules
```

⚠️ If `~/.claude/rules` already exists as a directory, `ln -s` puts the link *inside* it
and you get `~/.claude/rules/rules`, which loads nothing. Check with
`ls -la ~/.claude` first, and move anything already there out of the way.

⚠️ If you already have a `~/.claude/CLAUDE.md`, linking replaces it. Back it up first.

Verify:

```sh
ls -la ~/.claude | grep '\->'    # both links, each with a real target
ls ~/.claude/rules               # 8 files
```

Then start a session and run `/memory`. `CLAUDE.md` and the four always-on rules should
be listed. The other four rules carry `paths:` frontmatter and load only when Claude opens
a matching file, so their absence is correct.

Undo with `rm ~/.claude/CLAUDE.md ~/.claude/rules` — removing a symlink never touches the
file it points at.

### Try before you commit to anything

```sh
git clone https://github.com/Shaawwnn/sasasa.git
claude --plugin-dir ./sasasa
```

That loads the plugin for one session only. Nothing is installed, nothing is written to
`~/.claude`, and quitting ends it.

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

Two mechanisms, because no single one carries everything. Commands are in
[Using this yourself](#using-this-yourself); this section is the why.

**The plugin** carries `agents/`, `commands/`, `skills/` and `hooks/`. The repo is both
the plugin and its own marketplace — `marketplace.json` lists one plugin with
`"source": "./"` — so it installs from itself with no second repo to host.

Commands and skills are namespaced by the manifest's `name`, which is why they're
`/sa:tdd` rather than `/tdd`. Change one field in `.claude-plugin/plugin.json` to rename
the namespace. Namespacing also means nothing here can shadow a built-in command.

Hook script paths use `${CLAUDE_PLUGIN_ROOT}`, substituted for the plugin's own directory,
so the repo works from any location. Nothing is hard-coded to one machine.

**The symlinks** carry `CLAUDE.md` and `rules/`, which have no plugin equivalent. A
symlink is a signpost: `~/.claude/rules` holds nothing itself, it points here, and the
app follows it without knowing. One real copy, so an edit is live in the next session.

**`settings.json` is neither.** A plugin's root `settings.json` only honours the `agent`
and `subagentStatusLine` keys and silently ignores the rest, so the theme, TUI mode and
statusline here would do nothing as plugin defaults. It stays a plain copy of the live
file. After changing settings through the app, copy it back:
`cp ~/.claude/settings.json settings.json`.

Validate the manifests any time with `claude plugin validate .`.

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
