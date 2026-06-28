# ドキュメントペア一覧（cursor-playbook）

手順・コマンド・定数・禁止事項を変更するときは、**ペア両方**を同じ作業で更新する。  
同期ルール: [`docs/DOC_PAIR_SYNC.md`](DOC_PAIR_SYNC.md) / [`rules/generic/doc-pair-sync.mdc`](../rules/generic/doc-pair-sync.mdc)

| トピック | 正本 (.md) | Agent ルール (.mdc) |
|----------|------------|---------------------|
| ペア同期 | [`docs/DOC_PAIR_SYNC.md`](DOC_PAIR_SYNC.md) | [`rules/generic/doc-pair-sync.mdc`](../rules/generic/doc-pair-sync.mdc) |
| 共通 build / release | [`docs/COMMON_APP_RULES.md`](COMMON_APP_RULES.md) | [`rules/generic/common-app-rules.mdc`](../rules/generic/common-app-rules.mdc) |
| 見た目バグ切り分け | [`docs/DEBUG_VISUAL_BOUNDARY.md`](DEBUG_VISUAL_BOUNDARY.md) | [`rules/generic/debug-visual-boundary.mdc`](../rules/generic/debug-visual-boundary.mdc) |
| WinUI 第2ウィンドウ | [`docs/WINUI_SECOND_WINDOW.md`](WINUI_SECOND_WINDOW.md) | [`rules/winui/winui-second-window-borderless.mdc`](../rules/winui/winui-second-window-borderless.mdc) |

## 検証

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-doc-pairs.ps1
```

比較定義: [`scripts/doc-pairs.json`](../scripts/doc-pairs.json)
