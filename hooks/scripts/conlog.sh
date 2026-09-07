#!/usr/bin/env bash
#
# Fires on: PostToolUse, for Edit | Write | NotebookEdit
# Does:     tells Claude when a file it just edited still has console.log in it
#
# This one produces OUTPUT, unlike fmt.sh. See the bottom of the file for
# the JSON shape and why it matters.

payload=$(cat)

file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')

# Only JavaScript/TypeScript can contain console.log.
case "$file" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs) : ;;
  *) exit 0 ;;
esac

[ -f "$file" ] || exit 0

# Search for console.log and keep at most 5 matches.
#   grep -n     -> prefix each match with its line number
#   'console\.log' -> the backslash escapes the dot, which otherwise
#                     means "any character" in a regex
#   2>/dev/null -> ignore errors (unreadable file, etc.)
#   head -5     -> don't flood Claude's context with 200 hits
matches=$(grep -n 'console\.log' "$file" 2>/dev/null | head -5)

# Found nothing? Say nothing. `-n` tests "string is non-empty".
[ -n "$matches" ] || exit 0

# Build the JSON reply.
#
# `jq -n` builds a NEW object from scratch rather than reading input.
# `--arg NAME VALUE` safely injects a shell variable as a JSON string --
# it handles the quoting and escaping for us, which is why we don't
# hand-write the JSON with echo. Inside the jq program, \($name)
# interpolates that value.
#
# The shape matters. `additionalContext` is the field that puts text into
# CLAUDE's context, next to the tool result, so it can act on it.
# Writing to stderr instead would only reach the debug log, where nobody
# sees it -- on exit 0, stderr is not shown in the transcript.
jq -n \
  --arg file "$file" \
  --arg matches "$matches" \
  '{
     hookSpecificOutput: {
       hookEventName: "PostToolUse",
       additionalContext: "console.log left in \($file):\n\($matches)\nRemove before committing."
     }
   }'
