---
name: pr-screenshot
description: Add a screenshot of a change to its pull request (GitHub) or merge request (GitLab) description - capture the app showing the change (or use an image you give it), host it on a separate `pr-assets` branch that's never merged, and embed it in the PR body. Use when asked to "add a screenshot to the PR", "put the screenshot in the PR", "show the change in the PR", "attach this image to the MR", or "/pr-screenshot". Pass a PR number, an image path, or both.
---

# Add a screenshot to a PR

Arguments: whatever the user passed with the request (optional: a PR/MR number, a path to an
image, or what the screenshot should show)

The PR description ends up showing the screenshot, and the image stays out of the code
branches. Done when the PR body has the image in it and the image URL loads.

The CLIs can't upload attachments the way dragging an image into the web editor does, so the
image is pushed to a `pr-assets` branch: images only, no history shared with the code, never
merged. Every screenshot from every PR goes on that one branch.

Read the user's and the repo's agent instruction files (for example `AGENTS.md`, `CLAUDE.md`,
`~/.claude/CLAUDE.md`) first. Their rules win over these defaults.

## 1. Find the PR

- Host: `github.com` or a GitHub Enterprise host in `git remote get-url origin` means `gh`;
  `gitlab` means `glab` and "merge request".
- The PR: the number the user gave, else the current branch's
  (`gh pr view --json number,url,body` / `glab mr view`). If there's none, say so and stop,
  or offer to open one first.
- Visibility: `gh repo view --json visibility` / `glab repo view`. A public repo makes the
  image public to anyone, for good.

## 2. Get the image

- **The user gave a path:** use it. Look at it before going on.
- **The user didn't:** run the app the way the repo's README or instructions say, go to the
  page or state that shows the change, and screenshot it with whatever browser or screenshot
  tool you have. Frame it on the change (select the item, open the popup, and so on) at a
  normal desktop size. Stop any server you started once you're done.
- **You can't capture one:** ask the user for an image path.

Check what's in it before it goes anywhere: no secrets, tokens, internal URLs, other people's
data or personal details the user wouldn't want published. If anything's doubtful, ask. A
screenshot over about 2 MB is worth shrinking first (for example `sips -Z 1600` on macOS).

## 3. Upload it

From inside the repo:

```bash
bash scripts/upload-image.sh <image> pr-<number>-<short-slug>.png
```

(`scripts/` is next to this file.) It commits the image onto `pr-assets` in a throwaway
index, so the working tree and current branch aren't touched, keeps whatever's on the branch
already, and prints the URL to embed on its last line. It refuses a name that's already
taken; pick another rather than overwriting.

Then check the URL loads: `curl -sIL <url> | head -1` should say `200` for a public repo.
For a private one it only loads when signed in, so a redirect to a sign-in page is expected.

## 4. Put it in the description

Read the current body and keep all of it. Add the image with alt text that says what it shows:

```markdown
![<what the screenshot shows>](<url>)
```

- If the PR template has a screenshots section, put it there. Otherwise add it under
  `## Screenshot` at the end, or straight after the summary when the body is a few lines.
- If an earlier screenshot is there for the same thing, replace it rather than stacking them.
- Update with `gh pr edit <number> --body-file <tmpfile>` /
  `glab mr update <number> --description "$(cat <tmpfile>)"`.

## 5. Report

Give the PR URL, say where the image is stored, and say that deleting `pr-assets` breaks the
images in every PR that uses it. Mention that dragging an image into the PR's web editor is
the alternative that needs no branch.

## Rules

- Never commit the image to the PR's branch or the default branch.
- Never force-push or rewrite `pr-assets`: other PRs' images live there.
- Don't put anything in a screenshot you wouldn't publish; for a public repo it is published.
- No agent attribution in the PR body or the `pr-assets` commits, unless the repo's rules
  ask for it.
