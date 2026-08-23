---
name: github-project-setup
description: Create or reconcile a GitHub Projects v2 board with practical Status and Priority fields, visible card metadata, repository linkage, and optional PR-reference automation. Use when setting up, standardizing, auditing, or repairing a repository project board.
---

# GitHub Project Setup

Create a useful GitHub Projects v2 board while preserving existing work and repository-specific conventions.

Related skills:

- [github-repo-issue-setup](../github-repo-issue-setup/SKILL.md) manages labels.
- [github-issue-management](../github-issue-management/SKILL.md) manages day-to-day status changes.

## Recommended defaults

Use these when the user asks for a new standard board and the repository has no documented alternative.

Status, in order:

| Option | Color |
| --- | --- |
| Backlog | GRAY |
| Ready | BLUE |
| In progress | YELLOW |
| In review | PURPLE |
| Done | GREEN |

Priority:

| Option | Color | Meaning |
| --- | --- | --- |
| P0 | RED | Urgent correctness, security, or production blocker |
| P1 | YELLOW | Important confirmed work that is not an immediate blocker |
| P2 | GRAY | Lower-risk, speculative, or future work |

Use labels for issue type and the native Priority field for priority. Show both `Labels` and `Priority` on board cards.

Treat these as bootstrap defaults, not universal mandates. If an existing project uses different fields or stages, inspect their meaning and ask before a destructive reconciliation.

## Preflight

1. Resolve the target repository and owner.
2. Run `gh auth status`; project writes require `project` and `read:project` scopes.
3. List existing projects, fields, views, linked repositories, and items.
4. Identify changes that preserve IDs versus changes that would delete options or discard configuration.
5. Present any destructive or convention-changing operation before executing it.

## Create or link the project

Locate an existing board before creating one:

```bash
gh project list --owner <owner>
gh project create --owner <owner> --title "<Repository> Task Management"
gh project link <number> --owner <owner> --repo <owner>/<repo>
```

Do not create a duplicate board when a suitable one already exists.

## Configure fields safely

Read IDs with:

```bash
gh project field-list <number> --owner <owner> --format json
```

Prefer reusing an existing field and option ID so assigned items retain their values. The GraphQL `updateProjectV2Field` mutation replaces the complete single-select option list: include every option that must remain. Omitting an existing option deletes it.

If Priority is absent, create it:

```bash
gh project field-create <number> --owner <owner> \
  --data-type SINGLE_SELECT --name Priority \
  --single-select-options "P0,P1,P2"
```

Then update option colors and descriptions with `updateProjectV2Field`.

## Configure the board view

Query the board view's current visible field IDs before changing it. Add `Labels` and `Priority` while passing through every field already intended to remain visible.

The `updateProjectV2View` configuration replaces the full visible-field list. Never submit only the two new fields, because that can remove existing view configuration.

## Optional PR-reference automation

The bundled [workflow template](assets/pr-moves-issue-to-in-progress.yml) moves issues to `In progress` when a PR title or body references `#<issue-number>`.

Before copying or enabling this workflow, ask the user whether they want the CI automation implemented. Treat general approval to create or configure the project board as insufficient authorization for adding CI; proceed only after the user explicitly confirms the workflow.

To install it:

1. Copy it to `.github/workflows/pr-moves-issue-to-in-progress.yml` in the target repository.
2. Replace the `OWNER`, `REPO`, and `PROJECT_NUMBER` placeholders.
3. Review the trigger and status name against the target board.
4. Commit and push the workflow only when the user authorizes those repository changes.
5. Verify it exists on the default branch and inspect an actual workflow run.

The workflow requires a repository secret named `PROJECTS_TOKEN` whose token can write to the relevant Projects v2 board. Do not create, request, print, or store a token on the user's behalf. Explain the required permissions and let the user provision the secret through an approved credential workflow.

If the user does not want a long-lived token or repository automation, omit the workflow and document that transitions are manual.

## Verify

Before handoff, report:

- Project URL and repository linkage
- Status and Priority options
- Visible board fields
- Whether automation was omitted, installed only locally, or live on the default branch
- Any remaining manual credential or web-UI steps
