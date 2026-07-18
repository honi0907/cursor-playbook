# WinUI UI スレッド（async / オンライン更新）

<!-- pair: rules/winui/winui-ui-threading.mdc -->

WinUI 3 Desktop には WPF のような `SynchronizationContext` が無いことが多い。  
そのため `await` の継続が **スレッドプール** に乗り、そのあと XAML を触ると落ちる。

## 必須（禁止）

`await` のあとに、次を **そのまま** 触らない:

- `Button.IsEnabled` / `Visibility` などコントロールプロパティ
- `TextBlock.Text` など UI 要素への代入
- `ContentDialog.ShowAsync`（UI スレッド以外から）
- `Application.Current.Exit()` をスレッドプールから直接呼ぶ

`async void` イベントハンドラの `finally` で `IsEnabled = true` を書くのも典型的な落とし穴。  
未処理の `COMException (0x8001010E)` / `RPC_E_WRONG_THREAD` でプロセスが落ちる。

## 正しいパターン

1. UI スレッドで `DispatcherQueue` を確保する（`App` 起動時に保持するか、クリック時に取得）
2. `await` 後の UI 更新は必ず `dispatcher.TryEnqueue`（または `HasThreadAccess` 分岐）経由
3. `Progress<T>` に頼らない。WinUI ではハンドラがスレッドプールで呼ばれうる。報告も `TryEnqueue` する
4. HTTP / ファイル I/O は `ConfigureAwait(false)` でよい。UI に戻るときだけ Dispatcher を使う

```csharp
private async void OnUpdateClick(object sender, RoutedEventArgs e)
{
    var dispatcher = App.DispatcherQueue;
    Button.IsEnabled = false;
    try
    {
        var result = await DoWorkAsync().ConfigureAwait(false);
        RunOnUi(dispatcher, () => StatusText.Text = result);
    }
    finally
    {
        RunOnUi(dispatcher, () => Button.IsEnabled = true);
    }
}

static void RunOnUi(DispatcherQueue dq, Action action)
{
    if (dq.HasThreadAccess) action();
    else dq.TryEnqueue(() => action());
}
```

## 典型症状

| 観察 | 読み |
|------|------|
| 「オンライン更新」押下後に無言で終了 | `await` 後の `IsEnabled` / `Text` が別スレッド |
| Event Log: `COMException (0x8001010E)` | `RPC_E_WRONG_THREAD` |
| Faulting: `KERNELBASE` + `.NET Runtime` unhandled | `async void` の未処理例外でプロセス終了 |
| スタックに `Progress.InvokeHandlers` | `Progress<T>` が UI を直接更新している |

## Cursor ルール

`rules/winui/winui-ui-threading.mdc`

## 事例

- KM Timer 1.0.0 / 1.0.1: オンライン更新ボタンでアプリ終了 → 1.0.2 で Dispatcher 経由に修正
