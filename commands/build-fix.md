---
description: Fix build, compile, type, and lint errors incrementally until the build is green.
argument-hint: "[file or error text]"
---

Use the **build-error-resolver** agent.

Fix one error at a time: apply the smallest change, re-run the build, confirm that error is gone before moving on. Stop and report if a fix introduces new errors, or the same error survives three attempts.
