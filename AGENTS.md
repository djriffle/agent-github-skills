# Repository instructions

This repository distributes portable Agent Skills. Keep canonical skills under `skills/<skill-name>/SKILL.md`; do not duplicate platform-specific copies in `.claude`, `.agents`, or `.opencode` directories.

When asked to install these skills:

1. Identify the requested environment and use `scripts/install.sh --target claude`, `codex`, `opencode`, or `all`.
2. Use the default symlink mode unless the user requests standalone copies.
3. Never overwrite an existing skill. Report collisions and wait for the user to choose whether to preserve, replace, or rename them.
4. Verify that each destination contains every readable `SKILL.md` files.
5. Installation alone does not authorize commits, pushes, issue creation, project changes, secret creation, or other GitHub mutations.

When changing a skill, preserve portable Agent Skills frontmatter and run `./scripts/validate.sh` before handoff. Keep installation paths aligned with the official documentation linked from `README.md`.
