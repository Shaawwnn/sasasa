# Hooks

`scripts/` holds the hook code, one file each. `hooks.json` is a thin wiring file that
points at them by absolute path. Edit a script and the change is live — there is no copy
to keep in sync.

**Not symlinked.** Claude Code has no `~/.claude/hooks/` directory, so the `hooks` key
from `hooks.json` must be merged into `~/.claude/settings.json` by hand. The scripts stay
here - `hooks.json` points at them by absolute path, so editing a script is live
immediately, but editing `hooks.json` needs re-merging.

Not merged yet, so nothing here is running.

## Active hooks

| Script | Event | Matcher | Filter | What it does |
|---|---|---|---|---|
| `fmt.sh` | PostToolUse | `Edit\|Write\|NotebookEdit` | — | Runs Prettier on the edited file, if Prettier is installed |
| `conlog.sh` | PostToolUse | `Edit\|Write\|NotebookEdit` | — | Reports leftover `console.log` back to Claude |
| `prurl.sh` | PostToolUse | `Bash` | `if: Bash(gh pr create *)` | Surfaces the new PR's URL plus check/review commands |
| `stopaudit.sh` | Stop | (all) | — | At end of turn, flags `console.log` in files modified vs `HEAD` |

Every script is heavily commented and runs standalone. To try one, feed it the JSON a
hook would receive:

```sh
printf '{"tool_input":{"file_path":"/path/to/file.ts"}}' | hooks/scripts/conlog.sh
printf '{}' | hooks/scripts/stopaudit.sh
```

All four exit 0 and print nothing when they have nothing to say, so they never interrupt
a turn.

### The absolute path

`hooks.json` hard-codes `/Users/sasasa/projects/sasasa/hooks/scripts/`. That is the cost
of keeping the scripts as real files: move or rename this repo and the hooks stop firing,
silently. If this config ever needs to work on a second machine, that path is the one
thing to change.

`command` is `bash` and the script path goes in `args`. With `args` set, Claude Code
spawns the process directly instead of going through a shell, so the path needs no
quoting and nothing in it gets re-interpreted.

## Gotchas

Five things that make a hook silently do nothing. Worth re-reading before writing a new one.

**1. `matcher` matches the tool name, and nothing else.** It is either an exact name list
(`Bash`, `Edit|Write`) or, if it contains any other character, an unanchored JavaScript
regex — tested against the tool name alone. There is no expression syntax: you cannot
write `tool == "Bash" && tool_input.command matches "..."`. To filter on the command or
file path, use the `if` field, or test inside the script.

**2. Only `exit 2` blocks.** `exit 1` is a non-blocking error — the action proceeds
anyway, even though 1 is the conventional Unix failure code. A hook meant to enforce
something must exit 2.

**3. On exit 0, stderr goes to the debug log, not the transcript.** To say something
Claude will actually see, print JSON on stdout:

```json
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"..."}}
```

**4. PostToolUse gives you `tool_response`, not `tool_output`.** Its shape varies by tool,
so `jq -r '.tool_response | tostring'` is the safe way to search it as text.

**5. The matcher object takes only `matcher` and `hooks`.** The settings schema sets
`additionalProperties: false`, so a `description` key there is invalid — notes belong in
this file. Per-handler, the allowed fields are `type`, `command`, `args`, `timeout`,
`async`, `asyncRewake`, `shell`, `if`, and `statusMessage`.

Reference: https://code.claude.com/docs/en/hooks

## Deliberately not included

- **Block dev servers not started in tmux** — a hard block on every dev server, and it
  assumes tmux is always in play.
- **Pause before `git push` with `read -r`** — blocks on stdin, which hangs any
  non-interactive or agent-driven push.
- **Block writing any `.md`/`.txt`** — would block this README.
- **tmux reminder on install/test/build** — fires constantly; noise.
- **`tsc --noEmit` after every edit** — right idea, but it type-checks the whole project
  on every single edit. Worth adding back as `"async": true`, scoped to projects that
  actually have a `tsconfig.json`.

## Notes

- Prettier resolves `./node_modules/.bin/prettier` first, then a global install, then does
  nothing. It never invokes `npx`, which would hit the network.
- `prurl.sh` needs the GitHub CLI (`gh`), which is not installed on this machine. Until it
  is, that hook can never fire.
