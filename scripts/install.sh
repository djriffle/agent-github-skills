#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s --target <claude|codex|opencode|all> [--copy]\n' "$0"
}

target=""
mode="link"

while (($#)); do
  case "$1" in
    --target)
      if (($# < 2)); then
        usage >&2
        exit 2
      fi
      target="$2"
      shift 2
      ;;
    --copy)
      mode="copy"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$target" in
  claude|codex|opencode|all) ;;
  *)
    usage >&2
    exit 2
    ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo_dir="$(cd "$script_dir/.." && pwd -P)"

install_into() {
  local agent="$1"
  local destination="$2"
  local skill_dir skill_name installed_path

  mkdir -p "$destination"

  # Check every destination before installing anything for this agent.
  for skill_dir in "$repo_dir"/skills/*; do
    [[ -d "$skill_dir" && -r "$skill_dir/SKILL.md" ]] || continue
    skill_name="$(basename "$skill_dir")"
    installed_path="$destination/$skill_name"

    if [[ -e "$installed_path" || -L "$installed_path" ]]; then
      if [[ -L "$installed_path" && "$(readlink "$installed_path")" == "$skill_dir" ]]; then
        continue
      fi
      printf '%s: refusing to replace existing path: %s\n' "$agent" "$installed_path" >&2
      return 1
    fi
  done

  for skill_dir in "$repo_dir"/skills/*; do
    [[ -d "$skill_dir" && -r "$skill_dir/SKILL.md" ]] || continue
    skill_name="$(basename "$skill_dir")"
    installed_path="$destination/$skill_name"

    if [[ -e "$installed_path" || -L "$installed_path" ]]; then
      if [[ -L "$installed_path" && "$(readlink "$installed_path")" == "$skill_dir" ]]; then
        printf '%s: already installed: %s\n' "$agent" "$installed_path"
        continue
      fi
    fi

    if [[ "$mode" == "copy" ]]; then
      cp -R "$skill_dir" "$installed_path"
    else
      ln -s "$skill_dir" "$installed_path"
    fi
    printf '%s: installed %s\n' "$agent" "$installed_path"
  done
}

install_target() {
  case "$1" in
    claude)
      install_into "claude" "${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
      ;;
    codex)
      install_into "codex" "${CODEX_SKILLS_DIR:-$HOME/.agents/skills}"
      ;;
    opencode)
      install_into "opencode" "${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}"
      ;;
  esac
}

if [[ "$target" == "all" ]]; then
  install_target claude
  install_target codex
  install_target opencode
else
  install_target "$target"
fi
