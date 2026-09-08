# Git Workflow

## Commit Message Format

```
<emoji> <description>

<optional body>
```

Lead with the emoji that matches the kind of change. It carries meaning - never pick one
for decoration.

| Change | Emoji |
|---|---|
| New feature | ✨ |
| Bug fix | 🐛 |
| Refactor | ♻️ |
| Docs | 📝 |
| Tests | ✅ |
| Config, tooling, chore | 🔧 |
| Performance | ⚡ |
| CI | 👷 |
| Remove code or files | 🔥 |

One concern per commit. Never bundle unrelated changes.

## Attribution

Do not add Claude as an author or co-author. No `Co-Authored-By: Claude` trailer, no
"Generated with Claude Code" line, no tool attribution of any kind in commit messages
or PR bodies.

## Pull Request Workflow

When creating PRs:
1. Analyze full commit history (not just latest commit)
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft comprehensive PR summary
4. Include test plan with TODOs
5. Push with `-u` flag if new branch

## Feature Implementation Workflow

1. **Plan First**
   - Use **planner** agent to create implementation plan
   - Identify dependencies and risks
   - Break down into phases

2. **TDD Approach**
   - Use **tdd-guide** agent
   - Write tests first (RED)
   - Implement to pass tests (GREEN)
   - Refactor (IMPROVE)
   - Verify 80%+ coverage

3. **Code Review**
   - Use **code-reviewer** agent immediately after writing code
   - Address CRITICAL and HIGH issues
   - Fix MEDIUM issues when possible

4. **Commit & Push**
   - Detailed commit messages
   - Follow conventional commits format
