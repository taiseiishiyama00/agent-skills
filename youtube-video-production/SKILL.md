---
name: youtube-video-production
description: 設定済みYouTubeチャンネルの動画・Shortsを、チャンネルごとのワークフローと要求に従って制作・修正・検証するときに使用する。一般的なYouTube相談には使用しない。
---

# YouTube動画制作

チャンネルごとのワークフローと要求は `references/channels/<channel-id>/workflow.md` と `references/channels/<channel-id>/output-rules.md` にある。

AIはこれらを読み、各フェーズに記載されたMCP Toolを一意の実行入口として使用する。Toolにない処理を、場当たり的なシェルコマンドやリポジトリ編集で代替してはならない。

動画制作ワークフローの実行中は、`youtube-video-pipeline` と `youtube-remotion-renderer` を読み取り専用として扱う。Toolの不足や不具合によりいずれかのリポジトリを編集する必要が生じた場合は、制作を停止し、変更内容と理由を示してユーザーの許可を得てから編集する。

MCP Toolが未実装のフェーズは、既存のワークフローを維持し、実装済みとみなさない。Toolを追加する作業は動画制作とは別のパイプライン開発として扱う。

`output-rules.md` または `workflow.md` を変更した場合は、別のパイプライン開発で対応Toolも更新する。不要になった機能は残さず削除する。
