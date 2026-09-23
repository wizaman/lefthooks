# lefthooks

再利用可能な Lefthook の設定とフックスクリプトを提供するリポジトリです。

## 使い方

利用側リポジトリの `lefthook.yml` で、必要な設定を指定します。

```yaml
remotes:
  - git_url: https://github.com/wizaman/lefthooks
    ref: <release-tag>
    refetch_frequency: never
    configs:
      - configs/git/protect-default-branch.yml
```

`ref` には branch または tag を指定できます。省略した場合は、remote リポジトリの
既定ブランチが使用されます。commit SHA は指定できません。

共有設定が意図せず変更されないように、固定したリリースタグと
`refetch_frequency: never` を組み合わせる構成を推奨します。

既定ブランチや `main` などの変更可能な ref を追跡する場合は、`ref` を省略するか
branch を指定し、更新を取得する間隔を設定します。

```yaml
remotes:
  - git_url: https://github.com/wizaman/lefthooks
    refetch_frequency: 24h
    configs:
      - configs/git/protect-default-branch.yml
```

一度 `ref` を指定して利用した環境では、後から `ref` を削除せず、継続して指定して
ください。

その後、Git hook をインストールします。

```shell
lefthook install
```

1 つの共有設定に並列実行可能な複数の job が含まれる場合は、共有設定側で
`group` 化されます。利用側で定義する複数の job を並列実行する場合も、影響範囲を
限定できる `group` の使用を推奨します。

```yaml
pre-commit:
  jobs:
    - name: project checks
      group:
        parallel: true
        jobs:
          - run: check-a
          - run: check-b
```

remote からマージされた job を含め、hook 内のすべての job を並列実行する場合は、
利用側で hook レベルの `parallel` を指定します。実行順序や標準入力に依存する job が
ないことを確認してください。

```yaml
pre-commit:
  parallel: true
```

## 利用可能な設定

### `git/protect-default-branch.yml`

`origin` の既定ブランチへのコミットと、既定ブランチを更新する push を防止します。

## 開発

テストの実行には Just 1.31.0 以降が必要です。

利用可能なタスクを表示します。

```shell
just
```

すべてのテストを実行します。

```shell
just test
```

個別のテストは `test` module の recipe として実行できます。利用可能な recipe と
説明の表示、および個別実行の例は次のとおりです。

```shell
just --list test
just test::protect-default-branch
```
