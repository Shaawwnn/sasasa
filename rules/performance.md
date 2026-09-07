# Performance Optimization

## Model Selection Strategy

Current lineup: the Claude 5 family plus Haiku 4.5. In agent frontmatter use the short
names `opus`, `sonnet`, `haiku`; `/model` switches the session.

**Haiku 4.5** (fastest and cheapest; 200K context):
- Lightweight agents invoked frequently
- Mechanical work: extraction, classification, formatting
- Worker agents under an orchestrator

**Sonnet 5** (strong general coding model; 1M context):
- Main development work
- Orchestrating multi-agent workflows

**Opus 5** (the default for demanding work; 1M context):
- Complex architectural decisions
- Long-horizon agentic tasks
- Research and analysis

**Fable 5.1** (most capable widely released model; 1M context):
- The hardest reasoning and longest-horizon work only — it costs more than Opus

Every model above except Haiku 4.5 has a 1M context window.

Two levers that often matter more than which model you pick:
- **Effort** (`low` through `max`) — lower effort on a newer model frequently beats
  higher effort on an older one. `high` is usually the sweet spot; `max` when
  correctness outweighs cost; `low` for subagents and simple tasks.
- **Fast mode** (`/fast`) — runs Opus with faster output. It does not downgrade to a
  smaller model.

## Context Window Management

Avoid last 20% of context window for:
- Large-scale refactoring
- Feature implementation spanning multiple files
- Debugging complex interactions

Lower context sensitivity tasks:
- Single-file edits
- Independent utility creation
- Documentation updates
- Simple bug fixes

## Ultrathink + Plan Mode

For complex tasks requiring deep reasoning:
1. Use `ultrathink` for enhanced thinking
2. Enable **Plan Mode** for structured approach
3. "Rev the engine" with multiple critique rounds
4. Use split role sub-agents for diverse analysis

## Build Troubleshooting

If build fails:
1. Use **build-error-resolver** agent
2. Analyze error messages
3. Fix incrementally
4. Verify after each fix
