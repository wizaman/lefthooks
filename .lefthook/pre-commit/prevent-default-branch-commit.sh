#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/../lib/default-branch.sh"

remote_name="origin"
default_branch="$(get_default_branch "$remote_name")"
current_branch="$(git branch --show-current)"

if [[ "$current_branch" == "$default_branch" ]]; then
  echo "Commit blocked: ${remote_name}'s default branch (${default_branch}) is checked out." >&2
  echo "Create a feature branch, then retry your commit:" >&2
  echo "  git switch -c <type>/<description>" >&2
  exit 1
fi