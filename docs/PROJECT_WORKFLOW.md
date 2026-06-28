# プロジェクト運用フロー

新しいアプリを始めるとき・既存アプリに playbook を入れるとき・学びを還流するときの手順。

## 全体像（3層）

```
┌─────────────────────────────────────────────────────────┐
│  cursor-playbook（GitHub）                               │
│  汎用 .md + playbook-*.mdc                               │
│  例: 切り分け手順、build 運用、WinUI 第2ウィンドウ        │
└─────────────────────────────────────────────────────────┘
                          │ Install-CursorRules.ps1
                          ▼
┌─────────────────────────────────────────────────────────┐
│  各アプリの .cursor/rules/                               │
│  playbook-*.mdc  … playbook からコピー（上書き更新可）    │
│  myapp-*.mdc     … プロダクト固有（このリポジトリだけ）   │
└─────────────────────────────────────────────────────────┘
```

| 層 | 置き場所 | 命名 | 例 |
|----|---------|------|-----|
| 汎用 | cursor-playbook | `rules/generic/*.mdc` | `debug-visual-boundary` |
| スタック | cursor-playbook | `rules/winui/*.mdc` など | `winui-second-window-borderless` |
| プロダクト | 各アプリ `.cursor/rules/` | `<プロジェクト名>-*.mdc` | `kakipen-architecture` |

**使えるかどうかはアプリ次第。** WinUI でなければ `-Layers generic` だけでよい。

---

## A. 新しいアプリを始めるとき

### 1. playbook を clone（1回だけ、マシンに置く）

```powershell
cd C:\Users\k-mizukami\Desktop   # 好きな親フォルダ
git clone https://github.com/honi0907/cursor-playbook.git
```

clone 先は固定でなくてよい。`Install-CursorRules.ps1` のパスが分かればよい。

### 2. プロジェクトにルールを導入

```powershell
# 新規リポジトリのルートで .cursor/rules を作ってからでも可
.\cursor-playbook\scripts\Install-CursorRules.ps1 -ProjectPath "C:\path\to\my-new-app"
```

**WinUI 以外**（Web / Electron のみなど）:

```powershell
.\cursor-playbook\scripts\Install-CursorRules.ps1 -ProjectPath "C:\path\to\my-app" -Layers generic
```

入るファイル:

- `playbook-debug-visual-boundary.mdc`
- `playbook-common-app-rules.mdc`
- （`-Layers` に winui が含まれるとき）`playbook-winui-second-window-borderless.mdc`
- `.playbook-installed.json` … いつ入れたかの記録

### 3. プロジェクト固有ルールを足す

`.cursor/rules/` に `<プロジェクト名>-*.mdc` を新規作成する。

- ファイル名は **`myapp-architecture.mdc`** のようにプレフィックスを付ける
- `playbook-*` という名前は使わない（更新時に上書きされる）
- テンプレ: [templates/project-rule.mdc](../templates/project-rule.mdc)

例（kakipen）:

```
.cursor/rules/
  playbook-*.mdc          ← playbook から（手で編集しない）
  kakipen-architecture.mdc
  kakipen-build-run.mdc
  kakipen-external-display.mdc
```

### 4. プロジェクトに README を置く（推奨）

`.cursor/README.md` に次を書いておくと、後から自分も AI も迷わない。

```markdown
# Cursor ルール

- 汎用: cursor-playbook から `Install-CursorRules.ps1` で導入
- 専用: `myapp-*.mdc`
- 更新: `..\cursor-playbook\scripts\Install-CursorRules.ps1 -ProjectPath .`
```

（kakipen には既に `.cursor/README.md` あり）

### 5. 人間向けドキュメント（任意）

Electron 系は kakimoni-all のように `docs/BUILD_RULES.md` をプロジェクト内に置く。  
Cursor 汎用は playbook の `docs/` を参照すればよい。

---

## B. 既存アプリに playbook を後から足すとき

```powershell
.\cursor-playbook\scripts\Install-CursorRules.ps1 -ProjectPath "C:\path\to\existing-app"
```

- 既存の `myapp-*.mdc` は**触らない**
- `playbook-*.mdc` だけ上書き更新
- 以前ローカルだけに置いていた汎用ルールがあれば、playbook に移して削除を検討

---

## C. playbook を更新したとき

playbook リポジトリで `git pull` したあと:

```powershell
.\scripts\Install-UserCursorRules.ps1
.\scripts\Sync-AllProjects.ps1
```

（`Install-PlaybookHook.ps1` 済みなら `git pull` だけで上記が自動実行される）

各プロジェクトだけ更新する場合:

```powershell
.\cursor-playbook\scripts\Install-CursorRules.ps1 -ProjectPath "C:\path\to\your-app"
```

`playbook-*.mdc` のみ更新される。

ペア（`.md` / `.mdc`）を変更したときは push 前に:

```powershell
.\scripts\verify-doc-pairs.ps1
```

---

## D. 学びの還流（プロジェクト → playbook）

作業で得たノウハウを次のどちらに入れるか決める。

| 内容 | 入れ先 |
|------|--------|
| このプロダクトだけ（席 ID、API パス、画面構成） | `<プロジェクト名>-*.mdc` |
| どの WinUI アプリでも使える | `cursor-playbook/rules/winui/` + `docs/WINUI_*.md` |
| どのアプリでも使える（切り分け、build 運用） | `cursor-playbook/rules/generic/` + `docs/` |

### 還流の手順

1. cursor-playbook を clone / pull
2. `rules/` または `docs/` に追記・新規ファイル
3. 必要なら `Install-CursorRules.ps1` の `-Layers` に新しい層を足す（将来用）
4. commit & push
5. 各プロジェクトで `Install-CursorRules.ps1` を再実行

### プロジェクト側の整理

汎用化した内容が `myapp-*.mdc` に重複していたら、プロジェクト側は**ファイルパスなど固有部分だけ**残して playbook を参照する形に薄くする。

例（kakipen）:

```markdown
# kakipen-external-display.mdc

汎用の背景・禁止事項は playbook-winui-second-window-borderless.mdc を参照。

## 主要ファイル（kakipen 固有）
- DisplayWindow.xaml.cs … ShowOnDisplay
```

---

## E. やらないこと

- `playbook-*.mdc` をプロジェクト内で直接編集する（次回 install で消える）
- 汎用ルールを `myapp-*.mdc` にコピペし続ける（二重管理になる）
- 秘密情報・マシン固有パスを playbook に commit する
- kakimoni-all の `docs/` を playbook と二重にメンテし続ける（汎用は playbook に集約）

---

## F. チェックリスト（新規アプリ）

- [ ] cursor-playbook を clone した
- [ ] `Install-CursorRules.ps1` を実行した
- [ ] `<プロジェクト名>-architecture.mdc`（または相当）を作った
- [ ] `.cursor/README.md` に更新手順を書いた
- [ ] build 手順を `BUILD_RULES.md` または `*-build-run.mdc` に書いた
- [ ] 汎用化できた学びは playbook に還流した

---

## 関連リンク

- [CURSOR_START_HERE.md](CURSOR_START_HERE.md)
- [README.md](../README.md)
- リポジトリ: https://github.com/honi0907/cursor-playbook
