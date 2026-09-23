#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/../lib/default-branch.sh"

remote_name="${1:-origin}"
default_branch="$(get_default_branch "$remote_name")"
protected_ref="refs/heads/${default_branch}"

while read -r local_ref _ remote_ref _; do
  if [[ "$remote_ref" == "$protected_ref" ]]; then
    echo "Push blocked: ${local_ref} would update ${remote_name}'s default branch (${default_branch})." >&2
    echo "Push a feature branch instead." >&2
    exit 1
  fi
done