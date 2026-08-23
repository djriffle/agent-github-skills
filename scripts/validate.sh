#!/usr/bin/env bash
set -uo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo_dir="$(cd "$script_dir/.." && pwd -P)"
status=0
count=0

for skill_dir in "$repo_dir"/skills/*; do
  [[ -d "$skill_dir" ]] || continue
  count=$((count + 1))
  skill_file="$skill_dir/SKILL.md"
  directory_name="$(basename "$skill_dir")"

  if [[ ! -r "$skill_file" ]]; then
    printf 'ERROR %s: missing readable SKILL.md\n' "$directory_name" >&2
    status=1
    continue
  fi

  if [[ "$(sed -n '1p' "$skill_file")" != "---" ]]; then
    printf 'ERROR %s: SKILL.md must begin with YAML frontmatter\n' "$directory_name" >&2
    status=1
    continue
  fi

  closing_line="$(awk 'NR > 1 && $0 == "---" { print NR; exit }' "$skill_file")"
  name="$(awk 'NR > 1 && $0 == "---" { exit } /^name:[[:space:]]*/ { sub(/^name:[[:space:]]*/, ""); print; exit }' "$skill_file")"
  description="$(awk 'NR > 1 && $0 == "---" { exit } /^description:[[:space:]]*/ { sub(/^description:[[:space:]]*/, ""); print; exit }' "$skill_file")"

  if [[ -z "$closing_line" ]]; then
    printf 'ERROR %s: frontmatter is not closed\n' "$directory_name" >&2
    status=1
  fi
  if [[ "$name" != "$directory_name" ]]; then
    printf 'ERROR %s: frontmatter name is %s\n' "$directory_name" "${name:-<missing>}" >&2
    status=1
  fi
  if [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ || ${#name} -gt 64 ]]; then
    printf 'ERROR %s: name is not portable kebab-case (1-64 characters)\n' "$directory_name" >&2
    status=1
  fi
  if [[ -z "$description" || ${#description} -gt 1024 ]]; then
    printf 'ERROR %s: description must contain 1-1024 characters\n' "$directory_name" >&2
    status=1
  fi

  if [[ $status -eq 0 ]]; then
    printf 'OK %s\n' "$directory_name"
  fi
done

if [[ $count -eq 0 ]]; then
  printf 'ERROR: no skill directories found\n' >&2
  exit 1
fi

if [[ ! -r "$repo_dir/skills/github-project-setup/assets/pr-moves-issue-to-in-progress.yml" ]]; then
  printf 'ERROR: project setup workflow asset is missing\n' >&2
  status=1
fi

exit "$status"
