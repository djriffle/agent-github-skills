# agent-github-skills

Portable Agent Skills for consistent GitHub issue authoring, issue lifecycle management, repository label setup, and GitHub Projects v2 setup.

## Included skills

| Skill | Purpose |
| --- | --- |
| `github-issue-authoring` | Draft and file evidence-backed issues with one type label, project priority, and native sub-issue links. |
| `github-issue-management` | Inspect and move issues through project status stages and verify PR-to-issue links. |
| `github-project-setup` | Create or reconcile the standard Projects v2 board and PR-reference automation. |
| `github-repo-issue-setup` | Reconcile a repository's issue-label taxonomy without deleting repository-specific labels. |

The canonical skill directories live in [`skills/`](skills/). Each uses the portable `SKILL.md` format with only `name` and `description` frontmatter, so the same files can be installed in Claude Code, Codex, and OpenCode.

## Requirements

- [`gh`](https://cli.github.com/) authenticated for the repositories you manage
- `jq` for the project and issue-management commands
- GitHub CLI `project` and `read:project` scopes for Projects v2 work

The skills describe external mutations such as creating issues and changing project fields. Installing a skill does not authorize an agent to make those changes; the agent must still follow the user's requested scope and its environment's approval rules.

## Install

Clone the repository, then run the installer for your agent:

```bash
git clone https://github.com/djriffle/agent-github-skills.git
cd agent-github-skills
./scripts/install.sh --target codex
```

Supported targets are `claude`, `codex`, `opencode`, and `all`. The default installation uses symlinks, so a `git pull` updates the installed skills. Add `--copy` for independent copies instead.

```bash
./scripts/install.sh --target all
./scripts/install.sh --target claude --copy
```

Default destinations:

| Agent | Personal skill directory |
| --- | --- |
| Claude Code | `~/.claude/skills` |
| Codex | `~/.agents/skills` |
| OpenCode | `~/.config/opencode/skills` |

OpenCode also discovers the shared `~/.agents/skills` and Claude-compatible `~/.claude/skills` locations. Installing to its dedicated directory makes the intended OpenCode source explicit.

The installer never replaces an existing file or directory. Resolve a reported name collision yourself, then rerun it. See [INSTALL.md](INSTALL.md) for manual commands, project-local installation, verification, and a ready-to-use instruction for another coding agent.

## Use

Start a new agent session if newly installed skills are not detected automatically. Ask naturally, for example:

- “Create an issue for this failing test.”
- “Move issue #12 to In review.”
- “Set up a practical issue-label taxonomy for this repository.”
- “Create the standard GitHub Projects board for this repository.”

Codex also supports explicit `$github-issue-authoring` invocation; Claude Code exposes skills as slash commands; OpenCode loads them through its skill tool.

## Validate changes

```bash
./scripts/validate.sh
bash -n scripts/install.sh scripts/validate.sh
```

The validator checks portable names, required frontmatter, descriptions, and the bundled workflow asset.

## Sources for installation behavior

- [OpenAI: Build skills](https://developers.openai.com/codex/skills)
- [Anthropic: Extend Claude with skills](https://code.claude.com/docs/en/skills)
- [OpenCode: Skills](https://opencode.ai/v2/docs/skills)
