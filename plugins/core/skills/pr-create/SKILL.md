---
name: pr-create
description: Create a pull request (GitHub) or merge request (GitLab) for the current work - properly named branch, commit with a "why", the repo's PR template fully filled in, draft by default, previewed before anything is pushed. Use when asked to "create a PR", "open a PR", "put up a PR", "raise an MR", or "/pr-create". Pass "ready" to open it as ready for review instead of a draft.
---

# Create a PR

Arguments: $ARGUMENTS (optional: `ready`, or extra context about the change)

Repo and user rules win over these defaults. Read `~/.claude/CLAUDE.md`, the repo's
`CLAUDE.md`/`AGENTS.md`, `.claude/rules/` and `CONTRIBUTING.md` first, and follow any
branch, commit or PR rules they state.

## 1. Gather context

Run in parallel:

```bash
git remote get-url origin
git branch --show-current
git status --short
git fetch origin -q
git log --oneline -15
git branch -r --sort=-committerdate | head -30
```

- **Host:** `github.com` or a GitHub Enterprise host means `gh`; `gitlab` means `glab`
  and "merge request" instead of "PR". If unsure, use whichever of `gh repo view` /
  `glab repo view` succeeds.
- **Default branch (BASE):** `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name`
  (GitLab: `glab repo view`).
- **Conventions:** from the written rules above, else the patterns in recent branches,
  recent merged PRs (`gh pr list --state merged --limit 20 --json title,headRefName` /
  `glab mr list --merged`) and `git log`: branch naming, ticket prefixes,
  conventional commits, title casing.
- **Existing PR:** `gh pr view --json url,title,body` / `glab mr view` for the current
  branch.

## 2. Ticket

If the repo uses ticket IDs, take it from the branch, commits or conversation. If
none is found, ask. Don't invent one.

## 3. Pick the branch

- **On the default branch, or starting new work from a branch that has none of it
  committed yet:** create a branch matching the convention from the freshly fetched
  base: `git switch --no-track -c <name> origin/<BASE>`. Uncommitted changes come along.
- **On a branch that already has commits for this work:** use it. If its name doesn't
  match the convention, mention it but don't rename it without asking. If it's behind
  `origin/<BASE>`, say so, but don't rebase or merge without asking.

If switching fails because of local changes, stop and tell the user. Never stash,
reset or discard anything without asking.

## 4. Commit

If there are uncommitted changes:

- Commit only the files that belong to this change. If unrelated files are modified,
  ask which to include.
- Subject: match the repo's style (ticket prefix, conventional commits and so on).
- Body: a short **why**: the problem, what prompted it, and the outcome. Take it from
  the conversation and `$ARGUMENTS`, not the diff (the diff shows what, not why). If
  the why isn't clear, ask.

## 5. Write the title and description

**Title:** match recent merged PR titles.

**Template.** Look for one in this order (names are case-insensitive):
- GitHub: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/*.md`
  (if there are several, pick the one that fits or ask), `docs/pull_request_template.md`,
  `pull_request_template.md` at the root.
- GitLab: `.gitlab/merge_request_templates/*.md` (`Default.md` first).

If there's a template, fill in **every** section from the diff
(`git diff origin/<BASE>...HEAD`), the commits and the conversation. Keep its headings
and order.
- Why sections use the same reason as the commit body.
- Replace placeholders (ticket links, `<BRANCH_NAME>` in preview URLs and so on) with
  real values.
- Tick a checkbox only if it's true and you verified it. For an unticked testing box,
  say what was actually checked (commands run, results).
- Write "N/A" for sections that don't apply instead of deleting them.
- Remove the template's instruction comments (`<!-- ... -->`).

If there's no template, use:

```markdown
## Why
<the problem or ticket this solves; link it if known>

## What
<1-3 sentences or a short list: what this changes>

## How
<key decisions a reviewer should know; omit if trivial>

## Testing
<what was run or checked, and how a reviewer can verify it>
```

Write for a reviewer: lead with why, flag anything risky, name the important files
and don't narrate every one.

## 6. Preview and confirm

Before pushing anything, show:
- the title
- branch → base (with the base commit sha)
- commits and files changed, with counts
- draft or ready
- the full body

If a PR already exists for this branch, show the proposed description update instead.

Then ask: **Create PR** / **Edit description** / **Cancel**. This is the only
confirmation. After it's approved, run the rest without stopping.

## 7. Push and create

Write the body to a temp file, then:

```bash
git push -u origin HEAD
gh pr create --draft --base <BASE> --title "..." --body-file <tmpfile>
# ready: drop --draft. Existing PR: gh pr edit --body-file <tmpfile>
# GitLab: glab mr create --draft --target-branch <BASE> --title "..." --description "$(cat <tmpfile>)"
#         (add --remove-source-branch only if recent MRs do)
```

No agent attribution in commits or the PR body (no `Co-Authored-By`, no "Generated
with ..." lines), unless the repo's rules ask for it.

Print the PR URL and the branch the checkout is on now. Then stop. Don't wait for or
respond to review comments.
