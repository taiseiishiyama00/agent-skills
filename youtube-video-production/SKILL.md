---
name: youtube-video-production
description: 設定済みYouTubeチャンネルの動画・Shortsを、チャンネルごとの正本に従って制作・修正・検証するときに使用する。一般的なYouTube相談には使用しない。
---

# YouTube動画制作

対象チャンネルの次の正本を全文読む。

- `references/channels/<channel-id>/workflow.md`
- `references/channels/<channel-id>/output-rules.md`

この2ファイルは、人間が管理する要求の正本である。手順や実装より常に優先する。正本にない要求を追加せず、矛盾する実装は正本に合わせて直す。正本の変更は、ユーザーが明示的に依頼した場合だけ行う。

AIは正本を解釈し、必要な手段を対象リポジトリへ実装して、要求を満たしたことを検証する。実現方法はAIに委ねる。

AIは、正本と実装・設定・テストの対応だけを `references/channels/<channel-id>/implementation-map.md` に記録してよい。ここへ要求、例外、品質基準を追加してはならない。

対象チャンネルの正本がない場合は、制作や実装を始めず、ユーザーへ正本の作成を依頼する。
