# Git Workflow

## Commit Message Format

[gitmoji](https://gitmoji.dev), one space, capitalised description. No type prefix.

```
<emoji> <Description>

<optional body>
```

```
♻️ Refactor the hook path handling
✨ Added plugin manifest
```

| Emoji | For |
|---|---|
| ✨ | New feature |
| 🐛 | Bug fix |
| 🚑️ | Critical hotfix |
| 🩹 | Small fix for something non-critical |
| ♻️ | Refactor, no behaviour change |
| 🎨 | Improve structure or formatting of existing code |
| ⚡️ | Performance |
| 🔥 | Remove code or files |
| ⚰️ | Remove dead code |
| 🚚 | Move or rename files |
| 📝 | Documentation |
| 💡 | Comments in source |
| ✏️ | Typo |
| ✅ | Add, update, or pass tests |
| 🧪 | Add a failing test |
| 🔧 | Configuration files |
| 🔨 | Development scripts |
| 👷 | CI and workflows |
| 💚 | Fix a failing CI build |
| ⬆️ | Upgrade dependencies |
| ⬇️ | Downgrade dependencies |
| ➕ | Add a dependency |
| ➖ | Remove a dependency |
| 📌 | Pin a dependency to a version |
| 🔒️ | Fix a security or privacy issue |
| 🏷️ | Types |
| 🦺 | Validation |
| 🥅 | Error handling |
| 🔊 | Add logs |
| 🔇 | Remove logs |
| 🏗️ | Architectural change |
| 💥 | Breaking change |
| ⏪️ | Revert |
| 🚧 | Work in progress |
| 🎉 | Start a project |
| 🔖 | Release or version tag |
| 📄 | Add or update a license |
| 🙈 | .gitignore |

Full set at [gitmoji.dev](https://gitmoji.dev). Prefer the table - the rest exist, but a
log everyone can scan beats an exhaustive vocabulary.

One concern per commit. Never bundle unrelated changes.

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
