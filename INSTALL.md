# Installation guide

## Give this instruction to an agent

From the repository root, tell the agent:

> Install every skill in this repository's `skills/` directory for my default `<claude|codex|opencode>` environment. Use `./scripts/install.sh --target <target>`. Do not overwrite an existing skill. If a destination already exists, stop and show me the collision. After installation, verify that every installed skill directory contains a readable `SKILL.md`. Do not commit, push, or change GitHub state.

Use `all` as the target to install for all three environments.

## Automated installation

```bash
./scripts/install.sh --target claude
./scripts/install.sh --target codex
./scripts/install.sh --target opencode
```

Use `--copy` when you do not want installed skills linked to this checkout:

```bash
./scripts/install.sh --target all --copy
```

The environment variables `CLAUDE_SKILLS_DIR`, `CODEX_SKILLS_DIR`, and `OPENCODE_SKILLS_DIR` can override the corresponding destinations for testing or non-default layouts.

## Manual personal installation

Run the block for the environment you use. These commands create symlinks and intentionally fail if the same skill name is already installed.

### Claude Code

```bash
mkdir -p "$HOME/.claude/skills"
for skill in "$PWD"/skills/*; do
  ln -s "$skill" "$HOME/.claude/skills/$(basename "$skill")"
done
```

### Codex

```bash
mkdir -p "$HOME/.agents/skills"
for skill in "$PWD"/skills/*; do
  ln -s "$skill" "$HOME/.agents/skills/$(basename "$skill")"
done
```

### OpenCode

```bash
mkdir -p "$HOME/.config/opencode/skills"
for skill in "$PWD"/skills/*; do
  ln -s "$skill" "$HOME/.config/opencode/skills/$(basename "$skill")"
done
```

## Project-local installation

For skills checked into one target repository, copy or symlink the skill directories beneath the platform's project path:

| Agent | Repository-local directory |
| --- | --- |
| Claude Code | `.claude/skills/` |
| Codex | `.agents/skills/` |
| OpenCode | `.opencode/skills/` |

Codex and OpenCode both discover repository-local `.agents/skills/`, so that location is a useful shared choice. Claude Code requires `.claude/skills/` for its native project discovery.

## Verify

Filesystem verification works in every environment:

```bash
find "$HOME/.agents/skills" -maxdepth 2 -name SKILL.md -print
find "$HOME/.claude/skills" -maxdepth 2 -name SKILL.md -print
find "$HOME/.config/opencode/skills" -maxdepth 2 -name SKILL.md -print
```

If a running agent does not notice a newly created top-level skills directory, restart its session. In Codex, `/skills` lists available skills. In Claude Code, `/skills` opens the skills menu.
