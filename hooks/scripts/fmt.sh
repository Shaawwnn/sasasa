#!/usr/bin/env bash
#
# Fires on: PostToolUse, for Edit | Write | NotebookEdit
# Does:     runs Prettier on the file Claude just changed
#
# How every hook talks to Claude Code:
#   stdin  - a JSON object describing the tool call
#   stdout - print nothing = "no comment"; print JSON = "tell Claude this"
#   exit 0 - normal. (exit 2 would BLOCK the tool call. We never want that here.)

# Read the whole JSON payload from stdin into a variable.
# `$(...)` means "run this and substitute what it printed".
payload=$(cat)

# Pull the edited file's path out of the JSON.
#   jq -r     -> print a raw string, not a quoted one
#   // empty  -> if the field is missing, print nothing at all
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')

# Only handle file types Prettier understands.
# `case` is bash's pattern matcher. Each branch ends with `;;`.
# Anything that doesn't match falls through to `*)` and we stop quietly.
case "$file" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.css|*.scss|*.md)
    : ;;                # `:` is bash's built-in "do nothing"
  *)
    exit 0 ;;
esac

# The file could have been deleted or renamed since the edit.
#   -f     -> "exists and is a regular file"
#   a || b -> "if a failed, do b"
[ -f "$file" ] || exit 0

# Find Prettier. Prefer the project's own copy, so we respect the version
# and config that project pins. Fall back to a global install. Otherwise
# do nothing. We never call `npx`, which would download from the network
# in the middle of an edit.
if [ -x ./node_modules/.bin/prettier ]; then
  prettier=./node_modules/.bin/prettier
elif command -v prettier >/dev/null 2>&1; then
  prettier=prettier
else
  exit 0
fi

# Format the file in place.
#   >/dev/null 2>&1 -> throw away normal output AND errors. Anything we
#                      printed on stdout would be read as a decision, and
#                      we have no decision to make.
#   || true         -> a Prettier failure (say, a syntax error mid-edit)
#                      shouldn't make this hook look broken
"$prettier" --write "$file" >/dev/null 2>&1 || true

exit 0
