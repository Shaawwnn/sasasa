# sasasa

My personal Claude Code config: 9 agents, 9 commands, 2 skills, 4 hooks, 8 rules.

Agents own the procedures. Commands are thin entry points to them. Rules are always-on or
file-scoped preferences. One copy of anything.

## Install

```sh
claude plugin marketplace add Shaawwnn/sasasa
claude plugin install sa@sasasa
```

Commands are namespaced: `/sa:plan`, `/sa:tdd`, `/sa:build-fix`. Type `/sa:` for the list.

Installing turns on four hooks in every project: Prettier on edit (only if already
installed), and `console.log` reports on edit and at end of turn. None block. See
[hooks/README.md](hooks/README.md).

Remove with `claude plugin uninstall sa`.

<details>
<summary>Try it for one session instead</summary>

```sh
git clone https://github.com/Shaawwnn/sasasa.git
claude --plugin-dir ./sasasa
```

Nothing installed, nothing written to `~/.claude`.
</details>

## Rules and CLAUDE.md (optional)

Plugins can't carry these, so they're symlinked. **They're my preferences, not general
advice** - read them first, and copy instead of linking if you want to edit.

These need the repo on disk - the plugin install doesn't leave a copy.

```sh
git clone https://github.com/Shaawwnn/sasasa.git
cd sasasa
ln -s "$PWD/CLAUDE.md" ~/.claude/CLAUDE.md
ln -s "$PWD/rules"     ~/.claude/rules
```

Check with `ls -la ~/.claude`, then `/memory` in a session. Undo with `rm` on the links -
that never touches the files they point at.

<details>
<summary>Two ways this bites</summary>

If `~/.claude/rules` already exists as a directory, `ln -s` puts the link *inside* it and
nothing loads. If you already have a `~/.claude/CLAUDE.md`, linking replaces it.

Four rules load every session; four carry `paths:` frontmatter and load only when Claude
opens a matching file, so their absence from `/memory` is correct.
</details>

## Layout

| Path | What | Loads via |
|---|---|---|
| `agents/` | 9 subagents | plugin |
| `commands/` | 9 slash commands | plugin |
| `skills/` | 2 skills, `<name>/SKILL.md` | plugin |
| `hooks/` | 4 scripts + `hooks.json` | plugin |
| `CLAUDE.md` | global instructions | symlink |
| `rules/` | 8 rules | symlink |
| `settings.json` | theme, statusline | copy |
| `examples/` | sample config | not deployed |

<details>
<summary>Why two mechanisms</summary>

The plugin carries agents, commands, skills and hooks. The repo is both the plugin and its
own marketplace (`marketplace.json` lists one plugin with `"source": "./"`), so it installs
from itself. Hook paths use `${CLAUDE_PLUGIN_ROOT}`, so the repo works from anywhere.

`CLAUDE.md` and `rules/` have no plugin equivalent, hence the symlinks.

`settings.json` is neither: a plugin's root `settings.json` only honours `agent` and
`subagentStatusLine`, so the theme and statusline here would do nothing. It stays a copy -
`cp ~/.claude/settings.json settings.json` after changing settings in the app.
</details>

## Maintaining

- New agent, command, skill or rule: add the file. Live next session.
- New skill must be `skills/<name>/SKILL.md`. A flat `.md` is never discovered.
- Moving the repo breaks the two symlinks silently. The plugin half survives.
- Don't put anything in `~/.claude/agents/` - it silently overrides a plugin agent of the
  same name.
- `claude plugin validate .` after touching a manifest. CI runs it plus four structural
  checks.
