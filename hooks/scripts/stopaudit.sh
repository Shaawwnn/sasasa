#!/usr/bin/env bash
#
# Fires on: Stop -- when Claude finishes its turn
# Does:     one last sweep for console.log across everything changed
#           since the last commit, not just the files touched this turn
#
# fmt.sh and conlog.sh see one file at a time. This sees the whole diff,
# so it catches a console.log added three turns ago and forgotten.

# This hook ignores its input, but we still have to read stdin.
# A script that exits while something is writing to its pipe can hand the
# writer a "broken pipe" error, so we drain it and discard it.
cat >/dev/null

# Bail unless we're inside a git repo.
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# List files that differ from the last commit, keeping only JS/TS ones.
#   git diff --name-only HEAD -> paths only, no patch text
#   grep -E '\.(ts|tsx|...)$' -> $ anchors to the end of the name
#   || exit 0                 -> grep exits non-zero when nothing matched
changed=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(ts|tsx|js|jsx|mjs|cjs)$') || exit 0

[ -n "$changed" ] || exit 0

# Grep each changed file in turn.
#
# `while IFS= read -r line` is the safe way to loop over lines in bash:
#   IFS=     -> don't trim leading/trailing whitespace from the line
#   -r       -> don't treat backslashes as escape characters
# Together they keep filenames with spaces or odd characters intact.
#
# grep -H forces the filename into the output even when grepping a single
# file, so the result reads `app.ts:12:console.log(x)`.
matches=$(printf '%s\n' "$changed" | while IFS= read -r file; do
  [ -f "$file" ] || continue     # skip deleted files
  grep -Hn 'console\.log' "$file" 2>/dev/null
done | head -10)

[ -n "$matches" ] || exit 0

# Report to Claude. On the Stop event, additionalContext arrives at the end
# of the turn and the conversation continues, so Claude can act on it.
jq -n \
  --arg matches "$matches" \
  '{
     hookSpecificOutput: {
       hookEventName: "Stop",
       additionalContext: "Uncommitted files still contain console.log:\n\($matches)"
     }
   }'
