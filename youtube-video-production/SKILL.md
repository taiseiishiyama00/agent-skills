---
name: youtube-video-production
description: 設定済みYouTubeチャンネルの動画・Shortsを、共通ワークフローとチャンネルごとの要求に従って制作・修正・検証するときに使用する。一般的なYouTube相談には使用しない。
---

# YouTube動画制作

全チャンネル共通のワークフローは `references/workflow.md` にある。

チャンネルごとの要求は `references/channels/<channel-id>/output-rules.md` にある。

AIはこれらを読み、冪等かつ再現可能な手段を対象リポジトリへ実装する。

AIはチャンネルのディレクトリに、`.` で始まるファイルを作成してよい。その内容は、人間が書いた要求とAIが実装した手段の紐づけだけにする。
