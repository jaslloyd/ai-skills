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

```bash
scripts/new-skill.sh <skill-name>
```

This copies [`templates/skill/`](./templates/skill) to `plugins/core/skills/<skill-name>/` and fills in the name. Each skill folder looks like this:

```
plugins/core/skills/<skill-name>/
├── SKILL.md            # required: frontmatter (name, description) and the steps
├── REFERENCE.md        # optional: detail the agent reads only when SKILL.md links to it
├── scripts/            # optional: helper scripts the steps run
└── agents/openai.yaml  # optional: display name and short description in Codex
```

Then:

1. Write a good `description` in `SKILL.md`, since it decides when the skill triggers.
2. Delete `REFERENCE.md` and `scripts/` if the skill doesn't need them.
3. Add the skill to the table above and open a PR.

Keep skills generic: no employer code, secrets, internal URLs, company names or personal details. Keep them agent-neutral too: no `$ARGUMENTS` or tool names that only one agent has.

## License

[MIT](./LICENSE)
