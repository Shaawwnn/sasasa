---
description: Find and safely remove dead code, unused exports, and unused dependencies, verifying with tests.
argument-hint: "[path]"
---

Use the **refactor-cleaner** agent.

Run the full test suite before and after each deletion, and roll back anything that turns the suite red. Propose deletions rather than applying them wholesale.
