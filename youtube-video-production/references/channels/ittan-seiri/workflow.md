# 「いったん整理。」制作ワークフロー

## 制作物

- 1作品につき、横動画1本とShort1本を制作する。
- 制作物とレビュー対象はGoogle Driveに置く。

## Google Driveの構成

```text
<動画タイトル>/
├── source/
│   ├── scripts/
│   │   ├── long（横動画台本のGoogle Docs）
│   │   └── short
│   ├── assets/
│   │   ├── manifest.json
│   │   └── （作品固有の画像・動画・資料）
│   ├── audio/
│   │   ├── long/
│   │   │   ├── .segments/（TTS APIが返した生成音声）
│   │   │   ├── <章>.wav
│   │   │   ├── full.wav
│   │   │   └── manifest.json（発話時刻・出典を含む）
│   │   └── short/
│   │       ├── .segments/（TTS APIが返した生成音声）
│   │       ├── <章>.wav
│   │       ├── full.wav
│   │       └── manifest.json（発話時刻・出典を含む）
│   ├── visuals/
│   │   ├── long/
│   │   │   └── <章>/
│   │   │       ├── <scene-id>.png
│   │   │       └── manifest.json
│   │   └── short/
│   │       ├── <scene-id>.png
│   │       └── manifest.json
│   └── videos/
│       ├── long/
│       │   └── <章>.mp4
│       └── short/
│           └── video.mp4
├── output/
│   ├── long/
│   │   └── video.mp4
│   ├── short/
│   │   └── video.mp4
│   ├── thumbnail/
│   │   ├── long.jpg
│   │   └── short.jpg
│   └── 投稿情報/
│       ├── long.md
│       └── short.md
└── .pipeline/
```

## 台本作成フェーズ

[台本テンプレート](script-template.md)を参照し、横動画用とShort用の台本をそれぞれ `source/scripts` にGoogle Docsで作成する。

## MCP Toolによる制作フェーズ

各Toolの入力、処理、分岐、保存先、検証はToolのスキーマ、説明、実行結果に従う。

| 目的 | MCP Tool |
| --- | --- |
| Google Docs台本から音声と発話・出典manifestを生成する | `youtube-video-pipeline.generate_audio_from_google_doc` |
| 利用可能な描画コンポーネントを取得する | `youtube-video-pipeline.list_visual_components` |
| 音声manifestからシーン設計に必要な発話時刻と出典を取得する | `youtube-video-pipeline.get_video_scene_context` |
| 必要素材を収集し、座標・描画時間を含むシーン設計からレビュー用PNGを生成する | `youtube-video-pipeline.render_content_visuals_from_scene_plan` |
| 人間が確認した内容ビジュアルを承認する | `youtube-video-pipeline.approve_content_visuals` |
| 承認済みのシーン設計から章別MP4またはShortを生成する | `youtube-video-pipeline.render_video_from_approved_scene_plan` |
| 横動画の章別MP4を連結し、横動画とShortの完成版を配置する | `youtube-video-pipeline.finalize_reviewed_videos` |
| サムネイル、タイトル、概要欄などの投稿情報を作成する | `youtube-video-pipeline.create_youtube_post_assets` |
| 横動画またはShortをYouTubeへ限定公開で投稿する | `youtube-video-pipeline.upload_youtube_video` |
| 再投稿前に投稿記録と一致する非公開または限定公開動画を削除する | `youtube-video-pipeline.delete_uploaded_youtube_video` |
