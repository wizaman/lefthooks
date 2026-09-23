#!/usr/bin/env bash

get_default_branch() {
  local remote_name="$1"
  local default_ref

  default_ref="$(git symbolic-ref --quiet --short "refs/remotes/${remote_name}/HEAD" 2>/dev/null || true)"

  if [[ -z "$default_ref" ]]; then
    echo "Unable to determine ${remote_name}'s default branch from refs/remotes/${remote_name}/HEAD." >&2
    echo "Set the remote HEAD, then retry: git remote set-head ${remote_name} --auto" >&2
    return 1
  fi

  printf '%s\n' "${default_ref#"${remote_name}/"}"
}