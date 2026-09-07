---
name: youtube-video-production
description: 設定済みYouTubeチャンネルの動画・Shortsを、チャンネルごとのワークフローと要求に従って制作・修正・検証するときに使用する。一般的なYouTube相談には使用しない。
---

# YouTube動画制作

チャンネルごとのワークフローと要求は `references/channels/<channel-id>/workflow.md` と `references/channels/<channel-id>/output-rules.md` にある。

AIはこれらを読み、冪等かつ再現可能な手段を対象リポジトリへ実装する。

対象チャンネルに `references/channels/<channel-id>/.implementation-map.json` が存在する場合、AIは実装または修正の前に必ず読み、記載された実装入口、利用箇所、禁止対象、検証コマンドをたどる。変更後は対応する実装ハッシュと利用箇所を更新し、マップに記載された検証を実行する。

AIはチャンネルのディレクトリに、`.` で始まるファイルを作成してよい。その内容は、人間が書いた要求とAIが実装した上記手段の紐づけだけにする。
