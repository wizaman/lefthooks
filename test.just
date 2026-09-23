set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# すべてのテストを実行します。
all: validate shell-syntax protect-default-branch

# リポジトリ用および共有用の Lefthook 設定を検証します。
validate:
  lefthook validate
  LEFTHOOK_CONFIG=configs/git/protect-default-branch.yml lefthook validate

# Bash スクリプトの構文を検査します。
shell-syntax:
  bash -n \
    .lefthook/lib/default-branch.sh \
    .lefthook/pre-commit/prevent-default-branch-commit.sh \
    .lefthook/pre-push/prevent-default-branch-push.sh \
    tests/protect-default-branch.sh

# 既定ブランチへの commit と push が拒否されることを検証します。
protect-default-branch:
  bash tests/protect-default-branch.sh