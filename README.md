# ai-skills

The Claude Code skills I use every day for pull request work and for getting up to speed on new codebases.

They're small and plain Markdown, so copy them, change them and make them your own. They work with GitHub (`gh`) and GitLab (`glab`).

## Install

In Claude Code:

```
/plugin marketplace add jaslloyd/ai-skills
/plugin install core@jaslloyd-skills
```

Update later with `/plugin marketplace update jaslloyd-skills`.

## Skills

| Skill | What it does |
|---|---|
| [`/pr-create`](./plugins/core/skills/pr-create/SKILL.md) | Opens a PR/MR on a branch named to the repo's convention, with the PR template filled in |
| [`/pr-address`](./plugins/core/skills/pr-address/SKILL.md) | Checks review comments (human and AI), fixes the real ones, pushes, then optionally replies and resolves |
| [`/pr-feedback`](./plugins/core/skills/pr-feedback/SKILL.md) | Reviews a PR (optionally by number) for bugs, a11y and bad practices, verifies findings, drafts comments |
| [`/repo-onboarding`](./plugins/core/skills/repo-onboarding/SKILL.md) | Orientation on an unfamiliar codebase: stack, how to run it, layout, gotchas |

## Add a skill

1. Copy [`templates/SKILL.md`](./templates/SKILL.md) to `plugins/core/skills/<skill-name>/SKILL.md`.
2. Write a good `description`, since it decides when the skill triggers.
3. Open a PR.

Or ask Claude: "use skill-creator to make a new skill in this repo".

Keep skills generic: no employer code, secrets, internal URLs, company names or personal details.

## License

[MIT](./LICENSE)
