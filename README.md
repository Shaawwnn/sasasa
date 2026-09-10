# sasasa

My personal Claude Code config: 9 agents, 9 commands, 2 skills, 3 hooks, 8 rules.

Agents own the procedures. Commands are thin entry points to them. Rules are always-on or
file-scoped preferences. One copy of anything.

## Will this fit your stack

The agents adapt: each reads the project's own manifest and CI to find its build, test and
lint commands rather than assuming them. Those work anywhere.

Everything else leans JavaScript and TypeScript.

| | Fits |
|---|---|
| **Best** | TypeScript or JavaScript, React or Next.js, Prettier, GitHub with `gh` |
| **Fine** | Any JS/TS project. The React skill idles, the rest applies |
| **Partial** | Other languages. The 9 agents work; the 3 hooks and 4 of 8 rules never fire, and `frontend-patterns` is irrelevant |

What is JS/TS specific:

- **Hooks** run on `.ts .tsx .js .jsx .mjs .cjs` only. Prettier formatting and the
  `console.log` check do nothing elsewhere. One hook needs the GitHub CLI.
- **`frontend-patterns`** is React and Next.js.
- **4 of 8 rules** are scoped to JS/TS globs and stay dormant otherwise. `security.md` also
  covers Python, Go, Ruby, Java, SQL, shell, Terraform and config files.

What is not stack specific: all 9 agents, all 9 commands, `backend-patterns`, and the 4
always-on rules.

Nothing breaks on a stack it does not cover. The parts that do not apply simply never
trigger, so a Python or Go project still gets the agents and commands.

## Install

```sh
claude plugin marketplace add Shaawwnn/sasasa
claude plugin install sa@sasasa
```

Commands are namespaced: `/sa:plan`, `/sa:tdd`, `/sa:build-fix`. Type `/sa:` for the list.

Installing turns on three hooks in every project: Prettier on edit (only if already
installed), a `console.log` report on edit, and the PR URL after `gh pr create`. None
block. See [hooks/README.md](hooks/README.md).

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
| `examples/` | sample config | not deployed |

<details>
<summary>Why two mechanisms</summary>

The plugin carries agents, commands, skills and hooks. The repo is both the plugin and its
own marketplace (`marketplace.json` lists one plugin with `"source": "./"`), so it installs
from itself. Hook paths use `${CLAUDE_PLUGIN_ROOT}`, so the repo works from anywhere.

`CLAUDE.md` and `rules/` have no plugin equivalent, hence the symlinks.

`settings.json` is not in this repo. A plugin's root `settings.json` only honours `agent`
and `subagentStatusLine`, so a theme or statusline there would do nothing, and a copy just
drifts from the live file.
</details>

## Maintaining

- New agent, command, skill or rule: add the file. Live next session.
- New skill must be `skills/<name>/SKILL.md`. A flat `.md` is never discovered.
- Moving the repo breaks the two symlinks silently. The plugin half survives.
- Don't put anything in `~/.claude/agents/` - it silently overrides a plugin agent of the
  same name.
- `claude plugin validate .` after touching a manifest. CI runs it plus four structural
  checks.
