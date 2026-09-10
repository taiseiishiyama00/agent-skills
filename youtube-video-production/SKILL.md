---
name: youtube-video-production
description: 設定済みYouTubeチャンネルの動画・Shortsを、チャンネルごとのワークフローと要求に従って制作・修正・検証するときに使用する。一般的なYouTube相談には使用しない。
---

# YouTube動画制作

チャンネルごとのToolの利用目的と要求は `references/channels/<channel-id>/workflow.md` と `references/channels/<channel-id>/output-rules.md` にある。

AIはこれらを読み、MCP Toolを使うと明記されたフェーズでは対応Toolを一意の実行入口として使用する。内容ビジュアル画像の生成と作品固有のRemotion実装はMCP Toolを使わず、`workflow.md`の手順に従う。

`workflow.md` のMCP Toolを使う各フェーズには、目的とToolの対応だけを記載する。入力スキーマ、実行手順、分岐条件、保存先、検証条件はMCP Toolを正本とし、`workflow.md` へ複製しない。

動画制作ワークフローの実行中は、`youtube-video-pipeline`を読み取り専用として扱う。`youtube-remotion-renderer`は、作品固有の内容ビジュアルを`src/channels/<channel-id>/videos/<video-id>/`へ、対応画像を`public/input/<channel-id>/<video-id>/`へ追加・修正する場合に限り編集してよい。チャンネル共通・技術共通の実装変更が必要な場合は制作を停止し、変更内容と理由を示してユーザーの許可を得る。

MCP Toolを使うべきフェーズでToolが未実装の場合は、`workflow.md` で目的と未実装であることだけを示し、実装済みとみなさない。Toolを追加する作業は動画制作とは別のパイプライン開発として扱う。

`output-rules.md` の要求または `workflow.md` のTool対応を変更した場合は、別のパイプライン開発で対応Toolも更新する。不要になった機能は残さず削除する。
