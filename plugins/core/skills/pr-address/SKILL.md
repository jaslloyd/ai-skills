---
name: pr-address
description: Work through the review comments on the current branch's PR/MR, from teammates or AI reviewers (Copilot, CodeRabbit and so on). Check which are real issues, fix them, push, then optionally reply to and resolve the threads. Use when asked to "address the PR comments", "fix the review feedback", "handle the comments", or "/pr-address".
---

# Address PR review comments

Arguments: whatever the user passed with the request (optional: a PR/MR number; defaults to the PR for the current branch)

## 1. Find the PR and its open threads

Detect the host from `git remote get-url origin` (`gh` for GitHub, `glab` for GitLab).

Find the PR: use the number in the arguments if there is one, otherwise the PR for the current branch (`gh pr view --json number,url,headRefName,headRefOid` / `glab mr view`). If none exists, stop and say so. If a number was given and it's not the current branch, ask before checking it out.

Fetch **unresolved** feedback only:
- **GitHub inline threads** (the REST API doesn't expose resolved state, so use GraphQL):
  ```
  gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){pullRequest(number:$n){reviewThreads(first:100){nodes{id isResolved isOutdated path line comments(first:50){nodes{id databaseId author{login} body url}}}}}}}' -F o=OWNER -F r=REPO -F n=NUMBER
  ```
  Keep `isResolved: false`. Check outdated threads too, since the code may have moved rather than been fixed.
- **GitHub review bodies and general comments:** `gh pr view NUMBER --json reviews,comments`. These have no resolved state, so skip ones you've clearly already replied to.
- **GitLab:** `glab api projects/:id/merge_requests/NUMBER/discussions --paginate`. Keep discussions where a note is `resolvable: true` and `resolved: false`, plus general notes.

Skip pure noise: CI bots, coverage reports, "LGTM", and AI-reviewer summaries with nothing actionable.

## 2. Check every comment before touching code

For each comment, read the code it refers to **at the current HEAD**, with enough surrounding context to judge it. Then classify it:

| Verdict | Meaning |
|---|---|
| **Fix** | A real issue. You can explain the concrete problem it causes. |
| **Already fixed** | Fixed by a later commit. Note which one. |
| **Disagree** | Not a real issue, or the suggestion would make things worse. Give a specific reason. |
| **Question** | The reviewer asked something rather than requested a change. Draft an answer. |
| **Needs user** | Product, design, or scope decision you shouldn't make alone. |

Be especially sceptical of AI-reviewer comments. They often flag things that are handled elsewhere, suggest changes that break behaviour, or repeat themselves. Never "fix" something just because a comment asked for it.

Show the user a numbered triage table (comment author, file:line, one-line summary, verdict, reason). Ask them to confirm or override the verdicts before you change any code.

## 3. Fix, verify, push

- Make the fixes. Keep them minimal and on-topic. Don't refactor beyond what the comment asks.
- Run the repo's relevant tests, lint and typecheck. If something fails, fix it or report it. Don't push broken code.
- Commit following the repo's message style. One commit per logical fix is good if the repo cares about history; otherwise a single "Address review feedback" commit is fine.
- `git push`.

**Before moving on, confirm the push landed:** the remote PR head must equal local HEAD (`gh pr view --json headRefOid` / `glab mr view -F json` → `sha`, compared with `git rev-parse HEAD`). Don't draft "fixed" replies until this matches, because a reviewer must never see "done" on a thread whose fix isn't visible yet.

## 4. Replies and resolving (ask every time)

Draft a short reply for each thread:
- **Fix:** what changed and the commit short SHA, e.g. "Good catch, moved the null check before the map in abc1234."
- **Already fixed:** point to the commit.
- **Disagree:** the specific reason, politely, with an open door ("Happy to change it if you feel strongly").
- **Question:** the answer.
- **Needs user:** don't draft a reply. List it for the user.

Show all the drafts, then ask what to do:
1. Reply and resolve the fixed threads, and reply only on the rest
2. Reply only, and leave resolving to the reviewers
3. Pick per thread
4. Skip, and don't post anything

Never resolve a **Disagree** or **Question** thread. The reviewer should get the chance to respond.

How to post:
- **GitHub reply:** `gh api graphql -f query='mutation($t:ID!,$b:String!){addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$t,body:$b}){comment{url}}}' -f t=THREAD_ID -f b="..."`
- **GitHub resolve:** `gh api graphql -f query='mutation($t:ID!){resolveReviewThread(input:{threadId:$t}){thread{isResolved}}}' -f t=THREAD_ID`
- **GitHub general comment:** `gh pr comment NUMBER --body "..."`
- **GitLab reply:** `glab api -X POST projects/:id/merge_requests/NUMBER/discussions/DISCUSSION_ID/notes -f body="..."`
- **GitLab resolve:** `glab api -X PUT projects/:id/merge_requests/NUMBER/discussions/DISCUSSION_ID -f resolved=true`

Finish with a summary: fixed, disagreed, waiting on the user, and the PR URL.
