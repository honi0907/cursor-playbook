# Cursor ルール（プロジェクト名）

運用の全体像: [cursor-playbook docs/PROJECT_WORKFLOW.md](https://github.com/honi0907/cursor-playbook/blob/master/docs/PROJECT_WORKFLOW.md)

## 構成

| 種類 | ファイル | 管理 |
|------|---------|------|
| **汎用** | `playbook-*.mdc` | [cursor-playbook](https://github.com/honi0907/cursor-playbook) から導入 |
| **プロジェクト専用** | `<プロジェクト名>-*.mdc` | このリポジトリ |

## 初回セットアップ

```powershell
git clone https://github.com/honi0907/cursor-playbook.git
.\cursor-playbook\scripts\Install-CursorRules.ps1 -ProjectPath "."
```

## 汎用ルールの更新

```powershell
# playbook 側で git pull 後
..\cursor-playbook\scripts\Install-CursorRules.ps1 -ProjectPath "."
```

`playbook-*.mdc` のみ上書き。`<プロジェクト名>-*.mdc` は触らない。

## 学びの還流

- プロダクト固有 → このリポジトリの `<プロジェクト名>-*.mdc`
- 汎用化できた → cursor-playbook の `rules/` / `docs/` に PR または push

詳細は上記 PROJECT_WORKFLOW.md を参照。
