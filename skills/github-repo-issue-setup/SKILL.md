---
name: github-repo-issue-setup
description: Bootstrap, audit, or reconcile a GitHub repository's issue-label taxonomy while preserving repository-specific labels and avoiding duplicate priority systems. Use when setting up or standardizing labels and issue categories.
---

# GitHub Repository Issue Setup

Create a practical baseline label taxonomy without erasing a repository's existing conventions.

Related skills:

- [github-issue-authoring](../github-issue-authoring/SKILL.md) chooses labels for new issues.
- [github-project-setup](../github-project-setup/SKILL.md) configures native project priority.

## Recommended baseline

Use this set when bootstrapping a repository with no documented taxonomy:

| Label | Color | Description |
| --- | --- | --- |
| `bug` | `d73a4a` | Something is not working |
| `feature` | `0e8a16` | New capability or functionality |
| `enhancement` | `a2eeef` | Improvement to existing user-facing behavior |
| `refactor` | `fbca04` | Code restructuring with no intended behavior change |
| `chore` | `cfd3d7` | Maintenance: dependencies, cleanup, tooling, or CI |
| `performance` | `d93f0b` | Speed, memory, or scalability work |
| `documentation` | `0075ca` | Documentation additions or improvements |
| `question` | `d876e3` | Further information is requested |
| `needs-triage` | `ededed` | Not yet reviewed or categorized |
| `duplicate` | `cfd3d7` | This issue or pull request already exists |
| `invalid` | `e4e669` | This is invalid or not actionable |
| `wontfix` | `ffffff` | This will not be worked on |
| `good first issue` | `7057ff` | Suitable for a first contribution |
| `help wanted` | `008672` | Extra attention or outside help is welcome |

The first seven labels are primary work types. Prefer exactly one primary type per issue. The remaining labels are situational and can be combined with a primary type.

This is a fallback, not a reason to replace an established taxonomy. Preserve domain, component, team, release, and automation labels.

## Reconcile safely

1. Resolve the target repository from the request or `gh repo view --json nameWithOwner`.
2. Check authentication with `gh auth status`.
3. Read contribution guidance, issue templates, workflows, and all existing labels.
4. Compare existing labels with the requested or recommended baseline.
5. For each baseline label:
   - Create it if missing.
   - Update color or description only when that change preserves its established meaning.
   - Skip it when it already matches.
6. Never delete an unrecognized label. Ask before renaming, repurposing, or deleting any existing label.
7. Show a before/after summary and verify the final labels.

Useful commands:

```bash
gh label list --repo <owner>/<repo> --json name,color,description
gh label create "<name>" --repo <owner>/<repo> --color <hex> --description "<description>"
gh label edit "<name>" --repo <owner>/<repo> --color <hex> --description "<description>"
```

## Avoid duplicate priority systems

Before creating priority labels, inspect whether the repository's project uses a native Priority field. Prefer one priority system.

- If native project priority already exists, do not add `priority: *` labels.
- If the repository intentionally uses priority labels, preserve that convention.
- If neither exists and the user wants priority tracking, explain the tradeoff and use the method they choose.

A second run with the same desired taxonomy should make no changes.
