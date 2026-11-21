---
name: pr-feedback
description: Review a pull request/merge request for real bugs, accessibility issues and bad practices (for example, React anti-patterns), verify each finding, let the user choose which to raise, then draft copy-ready review comments. Use when asked to "review this PR", "review PR 45", "give feedback on this MR", or "/pr-feedback [number]".
---

# Review a PR

Arguments: $ARGUMENTS (optional: a PR/MR number. With no number, use the PR for the current branch.)

## 1. Find the PR and load context

Detect the host from `git remote get-url origin` (`gh` for GitHub, `glab` for GitLab).

- **Number given:** `gh pr view N --json title,body,author,baseRefName,headRefName,headRefOid,files,url` / `glab mr view N`.
- **No number:** look up the PR for the current branch. If there isn't one, say so and offer to review the branch's diff against the default branch instead.

Gather:
- Title, description and any linked issue/ticket, so you know what the change is meant to do.
- The diff: `gh pr diff N` / `glab mr diff N`.
- Existing review comments, so you don't repeat what others have already said.
- **Full file context** for changed files, not just diff hunks. Don't switch the user's working branch. Fetch the head (`git fetch origin pull/N/head` on GitHub, `git fetch origin merge-requests/N/head` on GitLab), then read files with `git show FETCH_HEAD:path`, or use a temporary `git worktree` if you need to run things.
- Repo conventions: CLAUDE.md, CONTRIBUTING, lint config, and nearby code that does similar things.

## 2. Look for problems

Go through the change looking for:
- **Bugs:** wrong logic, unhandled null/empty/error cases, race conditions, off-by-one errors, broken edge cases, behaviour that doesn't match the PR description.
- **Accessibility:** missing labels or alt text, non-semantic clickable elements (`div` with onClick), keyboard traps or unreachable controls, focus management in modals and route changes, colour-only meaning, missing ARIA where it's needed (and ARIA misuse where native HTML would do).
- **Framework best practices**, for example in React: missing or wrong `useEffect` dependencies, effects used for derived state, state that should be derived, unstable `key`s (indexes on reorderable lists), mutating state, unnecessary re-renders that matter, hooks called conditionally. Apply the equivalent standards for whatever stack the repo uses.
- **Security:** injection, XSS (`dangerouslySetInnerHTML`, unescaped output), secrets in code, missing auth checks.
- **Tests:** new behaviour with no tests, or tests that don't actually assert the thing they claim to.
- **Repo conventions:** places where the change ignores an established pattern in this codebase.

## 3. Verify every finding (most important step)

Before showing the user anything, try to prove each finding wrong:
- Is it handled elsewhere (a caller, a wrapper, a type, a validation layer)?
- Can you describe the concrete scenario where it breaks (input, then wrong result)?
- Does the codebase deliberately do it this way elsewhere?

Drop anything you can't back with a concrete failure or a clear, cited standard. Fewer real findings beat many speculative ones. Personal style preferences that the repo doesn't enforce are not findings.

## 4. Let the user choose

Show a numbered list, most important first:

```
1. [Bug · high confidence] src/cart/total.ts:42
   Average price divides by items.length with no empty check.
   Scenario: empty cart -> 0 / 0 -> NaN shown as "£NaN" in the summary.
```

Each entry gets a category, a confidence level, file:line, one line on what's wrong and why it matters, and the concrete scenario.

Ask which to raise (e.g. "1, 3, 4", "all", or "none"). The user can also ask you to dig deeper on any item first.

## 5. Draft copy-ready comments

For each selected finding, write a comment the user can paste straight into the PR:
- Put the **file:line** above each comment so they know where it goes.
- Use a friendly peer tone. Explain why, not just what. Suggest a fix (a code suggestion block is fine when it's short).
- Label how strongly you mean it where useful: "Blocking:", "Suggestion:", "Nit:", "Question:".
- Don't mention AI or that the comment was generated.

Output each one in its own fenced block so it's easy to copy. Don't post anything to the PR.
