# Common App Rules

KakiMoni 以外のアプリでも流用しやすい共通運用ルール。  
各アプリ固有の build 名、artifact 名、tag 名、配布物構成は各 `BUILD_RULES.md` 側に追加する。

## Build

- 変更が入った作業は、完了報告前に対象アプリの build を実行する。
- build 後は、成果物名と出力先が想定どおりか確認する。
- 古い成果物を残す運用は避け、配布フォルダには最新成果物だけを置く。

## Versioning

- version はリリースのたびに必ず上げる。
- 同じ version / tag の再利用はしない。
- patch が `9` まで進んだ次は繰り上げる。`X.Y.9 -> X.(Y+1).0`

## Release

- GitHub Release に載せる asset は事前に決め、不要な成果物は公開しない。
- Release 作成後は tag 名、asset 名、download URL を確認する。
- 同一 tag 内に旧 asset が混在しないようにする。

## Artifact Policy

- インストーラー、portable、zip、manifest など複数成果物がある場合は、公開対象とローカル保持対象を分けて明記する。
- asset 名は version を含め、ファイル名だけで内容が判別できるようにする。

## Update Distribution

- 自動更新を使う場合、manifest と配布 asset の参照関係を release 運用と一致させる。
- package に update 用 metadata を含める場合は、どのファイルを同梱し、実体をどこから取得するかを文書化する。

## Verification

- build 成功だけで終わらず、release 反映後の asset 一覧まで確認する。
- 運用ルールを変更したら、個別 `BUILD_RULES.md` と関連文書も同時に更新する。

## Cursor 向け

上記の要約は `rules/generic/common-app-rules.mdc` として Agent にも適用できる（`Install-CursorRules.ps1` で導入）。
