# cursor-playbook

Cursor / AI 向けの**汎用ルールとドキュメント**の置き場。  
プロジェクト固有のルール（例: `kakipen-architecture.mdc`）は各アプリの `.cursor/rules/` に残し、ここからは**共通化できるものだけ**を配布する。

## 何が入っているか

| 層 | 場所 | 用途 |
|----|------|------|
| 汎用 | `rules/generic/` | どのアプリでも（build 運用、UI 切り分け） |
| WinUI | `rules/winui/` | WinUI 3 / 第2ウィンドウ / UI スレッドなど |
| 人間向け | `docs/` | VSCode / Cursor 両方で読む `.md` |

## プロジェクトへの導入

**手順の詳細は [docs/PROJECT_WORKFLOW.md](docs/PROJECT_WORKFLOW.md) を読むこと**（新規アプリ・還流・更新）。

```powershell
# このリポジトリを clone 済みとして
.\scripts\Install-CursorRules.ps1 -ProjectPath "C:\path\to\your-app"

# ユーザー全体（全プロジェクト・全チャット）に generic ルールを常時適用
.\scripts\Install-UserCursorRules.ps1

# pull 後の自動同期フック（初回のみ）
.\scripts\Install-PlaybookHook.ps1

# 層を指定（既定: generic + winui）
.\scripts\Install-CursorRules.ps1 -ProjectPath "C:\path\to\your-app" -Layers generic
.\scripts\Install-CursorRules.ps1 -ProjectPath "C:\path\to\your-app" -Layers winui
```

- コピー先: `<プロジェクト>/.cursor/rules/playbook-*.mdc`
- **既存のプロジェクト固有ルールは上書きしない**（`kakipen-*` など）
- 更新時は同じコマンドを再実行

## 読む順番（人間・AI 共通）

1. [docs/PROJECT_WORKFLOW.md](docs/PROJECT_WORKFLOW.md) … **運用フロー（新規アプリ・還流）**
2. [docs/CURSOR_START_HERE.md](docs/CURSOR_START_HERE.md)
3. [docs/COMMON_APP_RULES.md](docs/COMMON_APP_RULES.md)
4. プロジェクト固有の `BUILD_RULES.md` / `.cursor/rules/<プロジェクト名>-*.mdc`

## 由来

- `docs/COMMON_APP_RULES.md` など … [kakimoni-all](https://github.com/honi0907/kakimoni) の VSCode 時代の運用を汎用化
- `rules/generic/debug-visual-boundary.mdc` … kakipen 外部出力白縁デバッグで確立した切り分け手順
- `rules/winui/winui-second-window-borderless.mdc` … WinUI 第2ウィンドウ DWM 白枠対策
- `rules/winui/winui-ui-threading.mdc` … WinUI `await` 後の UI 更新（オンライン更新クラッシュ等）

## ライセンス

社内・個人プロジェクトで自由にコピー・改変可。改善は PR または各プロジェクトからフィードバック。
