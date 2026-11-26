# ai-skills

The agent skills I use every day for pull request work and for getting up to speed on new codebases.

They're small, plain-Markdown [`SKILL.md`](https://agentskills.io) files, so they work in Claude Code, Codex and other agents that support skills. Copy them, change them and make them your own. They work with GitHub (`gh`) and GitLab (`glab`).

## Install

Pick one way per agent. Installing both a plugin and copied files gives you every skill twice.

<details>
<summary><strong>Claude Code</strong></summary>

```
/plugin marketplace add jaslloyd/ai-skills
/plugin install core@jaslloyd-skills
```

Update later with `/plugin marketplace update jaslloyd-skills`.

</details>

<details>
<summary><strong>Codex</strong></summary>

```bash
codex plugin marketplace add jaslloyd/ai-skills
codex plugin add core@jaslloyd-skills
```

Update later with `codex plugin marketplace upgrade jaslloyd-skills`.

</details>

<details>
<summary><strong>Any other agent, or editable files</strong></summary>

```bash
npx skills@latest add jaslloyd/ai-skills            # choose skills and agents interactively
npx skills@latest add jaslloyd/ai-skills -a cursor  # or name the agent
```

This copies the skills into your agent's skills folder. Update later with `npx skills@latest update`.

</details>

## Skills

| Skill | What it does |
|---|---|
| [`/pr-create`](./plugins/core/skills/pr-create/SKILL.md) | Opens a PR/MR on a branch named to the repo's convention, with the PR template filled in |
| [`/pr-address`](./plugins/core/skills/pr-address/SKILL.md) | Checks review comments (human and AI), fixes the real ones, pushes, then optionally replies and resolves |
| [`/pr-screenshot`](./plugins/core/skills/pr-screenshot/SKILL.md) | Screenshots the change (or takes your image), hosts it on a never-merged `pr-assets` branch and embeds it in the PR body |
| [`/pr-feedback`](./plugins/core/skills/pr-feedback/SKILL.md) | Reviews a PR (optionally by number) for bugs, a11y and bad practices, verifies findings, drafts comments |
| [`/repo-onboarding`](./plugins/core/skills/repo-onboarding/SKILL.md) | Orientation on an unfamiliar codebase: stack, how to run it, layout, gotchas |

## Add a skill

1. Copy [`templates/SKILL.template.md`](./templates/SKILL.template.md) to `plugins/core/skills/<skill-name>/SKILL.md`.
2. Write a good `description`, since it decides when the skill triggers.
3. Open a PR.

Or ask Claude: "use skill-creator to make a new skill in this repo".

Keep skills generic: no employer code, secrets, internal URLs, company names or personal details. Keep them agent-neutral too: no `$ARGUMENTS` or tool names that only one agent has.

## License

[MIT](./LICENSE)
