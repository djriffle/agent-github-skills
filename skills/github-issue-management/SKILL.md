---
name: github-issue-management
description: Inspect or change GitHub issue and project-board status, verify PR-to-issue relationships, and distinguish automated transitions from manual ones. Use for status checks or moves, PR linking, review handoffs, merges, closures, and multi-issue reporting.
---

# GitHub Issue Management

Keep repository issues, pull requests, and GitHub Projects v2 state consistent without assuming that a text reference or automation succeeded.

Related skills:

- [github-issue-authoring](../github-issue-authoring/SKILL.md) creates issues.
- [github-project-setup](../github-project-setup/SKILL.md) creates the optional default board and automation.

## Inspect before changing

Resolve the repository, project owner, and project number. List current items and fields before making a move:

```bash
gh project item-list <project-number> --owner <owner> --format json
gh project field-list <project-number> --owner <owner> --format json
```

Use the target project's actual Status options. A common flow is `Backlog → Ready → In progress → In review → Done`, but do not rename or invent stages during routine issue management.

A status-check request is read-only. Do not turn it into authorization to edit project state.

## Link pull requests correctly

For issues a PR actually resolves, put a literal closing keyword in the PR body: `Fixes #5`, `Closes #6`, or `Resolves #7`. Bare issue references do not populate GitHub's closing relationship.

Avoid closing-keyword-shaped prose for related issues that should remain open. Prefer wording such as “Related to issue #8; it remains open.”

After creating or editing a PR, verify the relationship:

```bash
gh api graphql -f query='
query {
  repository(owner: "<owner>", name: "<repo>") {
    pullRequest(number: <number>) {
      closingIssuesReferences(first: 20) { nodes { number } }
    }
  }
}'
```

Confirm that the returned issue set is exact. Add the PR itself to the project when the repository expects PR cards; linked issues do not guarantee that the PR is added automatically.

## Determine what is automated

Never infer automation from a local workflow file. Confirm that the workflow exists on the default branch and has successful runs:

```bash
gh api repos/<owner>/<repo>/contents/.github/workflows/pr-moves-issue-to-in-progress.yml --ref <default-branch>
gh run list --workflow=pr-moves-issue-to-in-progress.yml --repo <owner>/<repo>
```

The workflow bundled by [github-project-setup](../github-project-setup/SKILL.md) moves referenced issues to `In progress` on PR open, reopen, ready-for-review, or edit events. It does not handle every later transition.

Typical manual decisions are:

- Intake → Ready after triage
- Ready or Backlog → In progress when work starts and no live automation covers it
- In progress → In review when the change is ready for review
- In review → Done after merge or closure
- Invalid, duplicate, or superseded work → close with the appropriate label and move to the terminal status

Use repository-specific automation when it exists and verifies successfully.

## Move an item manually

1. Resolve or add the project item:

   ```bash
   gh project item-list <project-number> --owner <owner> --format json \
     | jq -r '.items[] | select(.content.number==<issue-number>) | .id'
   ```

   If absent, add it with `gh project item-add`.

2. Resolve the project ID, Status field ID, and target option ID once.
3. Set the field:

   ```bash
   gh project item-edit \
     --id <item-id> \
     --project-id <project-id> \
     --field-id <status-field-id> \
     --single-select-option-id <option-id>
   ```

4. Re-read the project item and verify the new status.

For a batch, resolve field IDs once, update all intended items, and report successes and failures together.
