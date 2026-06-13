# Cursor Start Here

**任意のプロジェクト**で AI（Cursor 等）に作業させる前の入口。

## 1. 汎用ルール（このリポジトリ）

1. [INDEX.md](INDEX.md)
2. [COMMON_APP_RULES.md](COMMON_APP_RULES.md)
3. 必要なら [DEBUG_VISUAL_BOUNDARY.md](DEBUG_VISUAL_BOUNDARY.md) / [WINUI_SECOND_WINDOW.md](WINUI_SECOND_WINDOW.md)

## 2. Cursor ルールの導入

```powershell
git clone https://github.com/honi0907/cursor-playbook.git
.\cursor-playbook\scripts\Install-CursorRules.ps1 -ProjectPath "C:\path\to\your-app"
```

## 3. プロジェクト固有

各リポジトリの `.cursor/rules/` にある `プロジェクト名-*.mdc` と `BUILD_RULES.md` を読む。

例:

- **kakipen** … `kakipen-architecture.mdc`, `kakipen-build-run.mdc`
- **kakimoni-all** … `docs/AI_HANDOFF.md`, 各 `BUILD_RULES.md`

## 4. 作業後

- 対象アプリの build を実行
- 汎用化できる学びがあれば **cursor-playbook** に還流、プロダクト固有は各リポジトリに残す

## 依頼文テンプレ

[AI_REQUEST_TEMPLATES.md](AI_REQUEST_TEMPLATES.md) をそのまま貼れる。
