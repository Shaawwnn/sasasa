# Driving Claude Code

Preferences for the harness itself, rather than for the code being written.

## Permissions

- Auto-accept suits trusted, well-defined plans; turn it off for exploratory work.
- Never use the `--dangerously-skip-permissions` flag.
- Grant standing permission with `permissions.allow` in `settings.json` rather than
  approving the same command repeatedly. `permissions` also takes `ask`, `deny`,
  `defaultMode` and `additionalDirectories`.

## Task tracking

Use `TaskCreate` and `TaskUpdate` to track multi-step work — set a task `in_progress`
when starting it and `completed` when it's done.

Worth doing because the list surfaces problems early. A task list makes visible:
- steps in the wrong order
- missing steps
- steps that shouldn't be there
- granularity that's too coarse or too fine
- a misread of what was asked

which is easier to correct at the list stage than after the work is done.

## Formatting

Prettier runs automatically on edited files via a PostToolUse hook, so don't reformat
by hand. The hooks themselves are documented in `hooks/README.md` — that's the single
source of truth for what fires and when.
