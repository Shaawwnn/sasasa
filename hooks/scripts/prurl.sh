#!/usr/bin/env bash
#
# Fires on: PostToolUse, for Bash -- and only when the command matched
#           `Bash(gh pr create *)` via the `if` filter in hooks.json
# Does:     spots the new pull request's URL and hands Claude the
#           follow-up commands for it
#
# NOTE: this needs the GitHub CLI (`gh`), which is not installed on this
# machine. Until it is, the hook can never fire -- `gh pr create` can't run.

payload=$(cat)

# Grab whatever the Bash tool returned.
#
# `.tool_response` is the field PostToolUse provides. There is no
# `.tool_output` -- reaching for that name silently finds nothing.
#
# Its shape varies by tool, so `tostring` flattens whatever is there --
# object or plain string -- into one blob of text we can search.
response=$(printf '%s' "$payload" | jq -r '.tool_response // empty | tostring' 2>/dev/null)

# Fish the PR URL out of that text.
#   grep -oE  -> -o prints only the matched part, not the whole line
#                -E enables extended regex (so + and | work unescaped)
#   [A-Za-z0-9_.-]+ matches an owner or repo name
#   head -1   -> if several URLs appear, take the first
url=$(printf '%s' "$response" \
  | grep -oE 'https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/pull/[0-9]+' \
  | head -1)

[ -n "$url" ] || exit 0

# Split the URL into the two pieces `gh` needs.
#
# `sed -E 's|PATTERN|REPLACEMENT|'` substitutes. We use | as the delimiter
# instead of the usual / so the slashes in the URL don't need escaping.
# The parentheses capture a group, and \1 refers back to it.
#
#   https://github.com/Shaawwnn/gcp/pull/42
#                      └── repo ──┘      └ number
repo=$(printf '%s' "$url" | sed -E 's|https://github.com/([^/]+/[^/]+)/pull/[0-9]+|\1|')
number=$(printf '%s' "$url" | sed -E 's|.*/pull/([0-9]+)|\1|')

# Hand Claude the URL plus two ready-to-run commands:
#   gh pr checks -> CI status for every GitHub Actions job on the PR
#   gh pr view   -> the PR body and its review comments, in the terminal
# These are printed as TEXT for Claude to read. Nothing here runs them.
jq -n \
  --arg url "$url" \
  --arg repo "$repo" \
  --arg number "$number" \
  '{
     hookSpecificOutput: {
       hookEventName: "PostToolUse",
       additionalContext: "PR created: \($url)\nChecks: gh pr checks \($number) --repo \($repo)\nReview: gh pr view \($number) --repo \($repo) --comments"
     }
   }'
