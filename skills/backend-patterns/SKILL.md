---
name: backend-patterns
description: Backend and API pattern checklist - which pattern to reach for and when. Use when designing endpoints, working with a database, adding caching, auth, rate limiting, or background jobs.
---

# Backend Patterns

A checklist of options, not a mandate. Stack-neutral - use the project's own database, cache, and queue.

## API Design
- Resource-shaped routes, plural nouns, HTTP verbs carrying the intent.
- One response envelope across every endpoint, errors included.
- **Repository** - isolate data access so business logic doesn't know the storage engine.
- **Service layer** - business logic lives here, not in route handlers. Handlers parse, delegate, and serialise.
- **Middleware** - cross-cutting concerns only: auth, logging, rate limiting, error handling.

## Database
- **N+1 prevention** - the most common real performance bug. Batch or join; never query inside a loop.
- Index what you filter and sort on. Verify with the query planner, not intuition.
- **Transactions** - any write touching more than one table. Keep them short.
- Select the columns you need.

## Caching
- Cache only what's expensive and read far more than written.
- **Cache-aside** - read cache, miss, read source, populate. Handle a cache outage by falling through to the source, never by failing the request.
- Every entry gets a TTL. Decide invalidation when you add the cache, not later.

## Errors
- **Centralised handler** - one place that maps internal errors to status codes and safe messages.
- **Retry with exponential backoff and jitter** - for transient failures only. Never retry a validation error.
- Distinguish expected failures from bugs; alert on bugs.

## Auth
- Verify the token's signature, expiry, and audience on every request. Never trust a decoded payload.
- Authorize per resource, not just per route - "can this user touch *this* record".
- **RBAC** - deny by default; grant explicitly.

## Rate Limiting
- Per identity and per endpoint, not one global limit.
- Return the limit, remaining, and reset so clients can back off.
- Shared storage if more than one instance serves traffic.

## Background Jobs
- Anything slow or externally-dependent leaves the request path.
- Jobs must be idempotent - they will run twice.
- A dead-letter path for repeated failures, and a way to inspect it.

## Logging
- Structured logs, with a request ID threaded through.
- Never log secrets, tokens, or personal data.
- Log the decision and the reason, not just that something happened.
