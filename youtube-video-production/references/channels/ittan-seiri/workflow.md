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
│   ├── references.json
│   ├── audio/
│   │   ├── long/
│   │   │   ├── .segments/（TTS APIが返した生成音声）
│   │   │   ├── <章>.wav
│   │   │   ├── full.wav
│   │   │   └── manifest.json
│   │   └── short/
│   │       ├── .segments/（TTS APIが返した生成音声）
│   │       ├── <章>.wav
│   │       ├── full.wav
│   │       └── manifest.json
│   ├── visuals/
│   │   ├── long/
│   │   │   └── <章>/
│   │   │       ├── <発話ID>.png
│   │   │       └── manifest.json
│   │   └── short/
│   │       ├── <発話ID>.png
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
│   ├── thumbnail
│   └── 投稿情報
└── .pipeline/
```

## 台本作成フェーズ

[台本テンプレート](script-template.md)を参照し、横動画用とShort用の台本をそれぞれ `source/scripts` にGoogle Docsで作成する。

## MCP Toolによる制作フェーズ

各Toolの入力、処理、分岐、保存先、検証はToolのスキーマ、説明、実行結果に従う。

| 目的 | MCP Tool |
| --- | --- |
| Google Docs台本から音声を生成する | `youtube-video-pipeline.generate_audio_from_google_doc` |
| 利用可能な描画コンポーネントを取得する | `youtube-video-pipeline.list_visual_components` |
| シーン設計に必要な作品情報を取得する | `youtube-video-pipeline.get_video_scene_context` |
| 内容ビジュアルで使う素材を収集する | `youtube-video-pipeline.collect_visual_assets` |
| レビュー用の内容ビジュアルPNGを生成する | `youtube-video-pipeline.render_content_visuals_from_scene_plan` |
| 人間が確認した内容ビジュアルを承認する | `youtube-video-pipeline.approve_content_visuals` |
| 承認済みのシーン設計から章別MP4またはShortを生成する | `youtube-video-pipeline.render_video_from_approved_scene_plan` |

## MCP Tool未実装のフェーズ

| 目的 | MCP Tool |
| --- | --- |
| 横動画の章別MP4を連結し、横動画とShortの完成版を配置する | 未実装 |
| サムネイル、タイトル、概要などの投稿情報を作成する | 未実装 |
| 横動画とShortをYouTubeへ限定公開で投稿し、投稿情報、関連動画、終了画面を設定する | 未実装 |
