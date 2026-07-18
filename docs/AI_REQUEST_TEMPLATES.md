# AI Request Templates

他の AI にそのまま貼るための依頼テンプレ。  
最初に [CURSOR_START_HERE.md](CURSOR_START_HERE.md) と [COMMON_APP_RULES.md](COMMON_APP_RULES.md) を読ませる前提。

## 1. 不具合修正

```text
まず docs/CURSOR_START_HERE.md と COMMON_APP_RULES.md と対象プロジェクトの BUILD_RULES.md（あれば）を読んでください。
生成物やバックアップフォルダは編集せず、本体ファイルだけを修正してください。

症状:
- ここに書く

期待動作:
- ここに書く

作業条件:
- 必要最小限の変更にする
- 変更後は関係 build を実行する
- 何を直したか、どのファイルを触ったか、build 実行結果を最後に報告する
```

## 2. UI の見た目（縁・余白・枠）

```text
まず DEBUG_VISUAL_BOUNDARY.md を読んでください。
修正を積む前に、縁が OS 枠かコンテンツかを切り分けてから対応してください。

症状:
- ここに書く（スクショがあれば添付）

切り分け:
- コンテンツ縮小 or 背景色変更で縁が動くか確認済みか
```

## 3. WinUI 第2ウィンドウ / 外部モニター

```text
まず WINUI_SECOND_WINDOW.md を読んでください。
フルスクリーン時に AppWindow.MoveAndResize と Win32 WS_POPUP を同時に使わないでください。

症状:
- ここに書く
```

## 4. WinUI async / オンライン更新で落ちる

```text
まず WINUI_UI_THREADING.md を読んでください。
await のあとに IsEnabled / Text / ContentDialog をそのまま触らないでください。DispatcherQueue 経由にしてください。

症状:
- ボタン押下後にアプリが無言終了する、など
```

## 5. リリース

```text
まず COMMON_APP_RULES.md と対象 BUILD_RULES.md を読んでください。

version:
- ここに書く

公開 asset:
- ここに書く
```
