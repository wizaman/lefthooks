#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

assert_success() {
  local description="$1"
  shift

  if ! output="$("$@" 2>&1)"; then
    echo "Expected success: ${description}" >&2
    echo "$output" >&2
    exit 1
  fi
}

assert_failure() {
  local description="$1"
  local expected="$2"
  shift 2

  if output="$("$@" 2>&1)"; then
    echo "Expected failure: ${description}" >&2
    exit 1
  fi

  if [[ "$output" != *"$expected"* ]]; then
    echo "Expected output to contain: ${expected}" >&2
    echo "$output" >&2
    exit 1
  fi
}

run_pre_commit() {
  (cd "$test_root" && lefthook run pre-commit --force --no-auto-install)
}

run_pre_push() {
  local refs="$1"
  printf '%s' "$refs" |
    (cd "$test_root" && lefthook run pre-push origin https://example.invalid/repository.git --force --no-auto-install)
}

mkdir -p "$test_root/.lefthook"
cp -R "$repository_root/.lefthook/." "$test_root/.lefthook/"
cp "$repository_root/configs/git/protect-default-branch.yml" "$test_root/lefthook.yml"

git -C "$test_root" init --quiet --initial-branch=main
git -C "$test_root" config user.email test@example.com
git -C "$test_root" config user.name Test
git -C "$test_root" commit --quiet --allow-empty --message initial
git -C "$test_root" remote add origin https://example.invalid/repository.git
git -C "$test_root" update-ref refs/remotes/origin/main HEAD
git -C "$test_root" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main

assert_failure "commit on the default branch" "Commit blocked" run_pre_commit

git -C "$test_root" switch --quiet --create feature/test
assert_success "commit on a feature branch" run_pre_commit

head_oid="$(git -C "$test_root" rev-parse HEAD)"
zero_oid="0000000000000000000000000000000000000000"
feature_update="refs/heads/feature/test ${head_oid} refs/heads/feature/test ${zero_oid}"
default_update="refs/heads/feature/test ${head_oid} refs/heads/main ${zero_oid}"

assert_failure "push to the default branch" "Push blocked" run_pre_push "${default_update}"$'\n'
assert_success "push to a feature branch" run_pre_push "${feature_update}"$'\n'
assert_failure \
  "push containing the default branch after another ref" \
  "Push blocked" \
  run_pre_push \
  "${feature_update}"$'\n'"${default_update}"$'\n'

git -C "$test_root" symbolic-ref --delete refs/remotes/origin/HEAD
missing_head_message="git remote set-head origin --auto"
assert_failure "commit without origin/HEAD" "$missing_head_message" run_pre_commit
assert_failure "push without origin/HEAD" "$missing_head_message" run_pre_push "${feature_update}"$'\n'

echo "protect-default-branch tests passed"