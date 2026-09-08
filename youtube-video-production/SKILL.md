---
name: youtube-video-production
description: 設定済みYouTubeチャンネルの動画・Shortsを、チャンネルごとのワークフローと要求に従って制作・修正・検証するときに使用する。一般的なYouTube相談には使用しない。
---

# YouTube動画制作

チャンネルごとのワークフローと要求は `references/channels/<channel-id>/workflow.md` と `references/channels/<channel-id>/output-rules.md` にある。

AIはこれらを読み、冪等かつ再現可能な手段を対象リポジトリへ実装する。具体的にはすべてのワークフロー作業はyoutube-video-pipelineを使うことによって実現する。
ワークフロー中にyoutube-video-pipelineおよびyoutube-remotion-rendererに変更を加えてはいけない。機能が足りていない場合はユーザーに許可をとること。
