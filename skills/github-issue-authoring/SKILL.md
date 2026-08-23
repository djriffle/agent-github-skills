---
name: github-issue-authoring
description: Draft or file clear GitHub issues using a repository's existing templates and labels, with evidence, project fields, and native sub-issue links when applicable. Use for bugs, failing tests, features, refactors, chores, enhancements, documentation, or performance work.
---

# GitHub Issue Authoring

Create issues that are reproducible, correctly classified, and consistent with the target repository.

Related skills:

- [github-repo-issue-setup](../github-repo-issue-setup/SKILL.md) defines a recommended fallback label taxonomy.
- [github-project-setup](../github-project-setup/SKILL.md) defines recommended project fields.
- [github-issue-management](../github-issue-management/SKILL.md) manages later status changes and PR links.

## Establish the repository conventions

Before drafting or filing:

1. Resolve the target repository from the request or `gh repo view --json nameWithOwner`.
2. Inspect `.github/ISSUE_TEMPLATE/`, contribution guidance, existing labels, and a few recent well-formed issues.
3. Prefer explicit repository conventions over this skill's defaults. Do not create labels, fields, or a project board merely to file one issue.
4. Search open issues for likely duplicates.
5. Distinguish a requested draft from authorization to create an issue. Draft-only requests must not mutate GitHub.

## Choose one primary type

Use the repository's taxonomy when it has one. Otherwise use one of these defaults:

| Situation | Label |
| --- | --- |
| Confirmed defect on a real code path | `bug` |
| New capability | `feature` |
| User-facing improvement to existing behavior | `enhancement` |
| Restructuring with no intended behavior change | `refactor` |
| Dependencies, tooling, CI, or maintenance | `chore` |
| Documentation-only change | `documentation` |
| Speed, memory, or scalability | `performance` |

Do not label missing functionality as a regression. Apply one primary type; add situational labels such as `needs-triage`, component labels, or `help wanted` only when repository conventions support them.

## Draft the body

For a defect or failing test, use the repository template when present. Otherwise include:

```markdown
## Reproduction
Exact command, input, or minimal sequence that triggers the problem.

## Observed behavior
Relevant error or concise output, trimmed to useful evidence.

## Expected behavior
What should happen instead.

## Root cause or investigation
Confirmed cause with file and line pointers, or clearly labeled hypotheses and remaining unknowns.

## Suggested direction
One or two concrete options, relevant risks, and explicit scope boundaries.
```

Name exact failing tests and `path/to/file:line` locations when they are known. Do not invent a root cause or line number when investigation has not established one.

For a feature, enhancement, refactor, or chore without a reproduction:

```markdown
## Problem
The user need or concrete maintenance problem.

## Proposed outcome
Observable behavior or end state, without over-prescribing the implementation.

## Acceptance criteria
- Verifiable result
- Important compatibility or quality constraint

## Scope
Included work, exclusions, dependencies, and risks.
```

For broad audits, group findings by risk or subsystem rather than making one flat checklist.

## Create and enrich the issue

When the user has asked to file it:

1. Create it with the chosen primary label:
   `gh issue create --repo <owner>/<repo> --title "<title>" --body-file <file> --label "<label>"`.
2. Add it to a project only if the repository uses one and the request or established workflow calls for it:
   `gh project item-add <project-number> --owner <owner> --url <issue-url>`.
3. If the project has a Priority field, set it using the project's documented meanings. A useful default is:
   - P0: urgent correctness, security, or production blocker
   - P1: important confirmed work that is not an immediate blocker
   - P2: lower-risk, speculative, or future work
4. Leave Status at the project's intake default unless work has visibly begun.
5. Verify the created issue's title, body, labels, project membership, and fields.

Do not create priority labels when the repository tracks priority in a project field. If the repository already uses priority labels instead, follow its convention rather than silently migrating it.

## Link native sub-issues

When an issue is explicitly a child of another, create GitHub's native relationship in addition to any readable body reference:

```bash
child_database_id=$(gh api repos/<owner>/<repo>/issues/<child-number> --jq '.id')
gh api repos/<owner>/<repo>/issues/<parent-number>/sub_issues \
  -X POST -F sub_issue_id="$child_database_id"
```

The endpoint needs the issue database ID, not the issue number. Use `-F` so the ID is sent as an integer. Verify the parent reports the child after the call.
