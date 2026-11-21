---
name: repo-onboarding
description: Get up to speed on an unfamiliar codebase. Use when starting at a new job or joining a new repo, or when asked to "explain this repo", "how do I run this", or "onboard me".
---

# Repo onboarding

Produce a short, practical orientation for a codebase the user has never seen.

1. Read the README, CONTRIBUTING, and any CLAUDE.md/AGENTS.md files.
2. Identify the stack from manifests (package.json, pyproject.toml, go.mod, Gemfile, etc.).
3. Find how to install, run, test, and lint, from scripts, Makefile, and CI config. Prefer what CI actually runs over what the README claims.
4. Map the top-level directories to what they do (one line each).
5. Trace one real request or feature end to end so the user sees how the pieces connect.
6. List gotchas: required env vars, services that must be running, flaky or slow tests.

Output a single summary with these headings: **Stack**, **Run it**, **Layout**, **One flow end to end**, **Gotchas**. Keep it under one screen.
