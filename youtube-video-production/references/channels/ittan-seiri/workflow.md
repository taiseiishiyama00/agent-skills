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
│   │   │       └── <visual-id>.png
│   │   └── short/
│   │       └── <visual-id>.png
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

## Image 2.5による内容ビジュアル生成フェーズ

このフェーズではMCP Toolを使わない。台本に記載されたすべてのビジュアル挿入位置を抽出し、挿入位置ごとにImage 2.5で1枚の内容ビジュアル画像を生成する。各生成時には、局所的な発話だけでなく台本全体と対象の挿入位置をコンテキストとして与え、作品全体の意味、前後関係、重複しない構図を反映させる。

生成画像はGoogle Driveの`source/visuals/long/<章>/<visual-id>.png`または`source/visuals/short/<visual-id>.png`へ保存する。画像生成、保存、確認に`youtube-video-pipeline`のMCP Toolを追加・使用しない。

## Remotionによる内容ビジュアル実装フェーズ

内容ビジュアル画像の確認と音声加工の完了後、`get_content_visual_timeline`で各`visualId`の正確な表示開始、終了、尺、frame数を取得する。その後の実装自体にはMCP Toolを使わない。画像と確定尺を確認し、内容と構図に合う登場、移動、拡大、強調、場面転換等のアニメーションを作品固有のRemotionコードとして実装する。

- `youtube-remotion-renderer/src/channels/ittan-seiri/videos/<video-id>/`を作り、`index.tsx`を置く。
- Google Driveで確認済みの画像を`youtube-remotion-renderer/public/input/ittan-seiri/<video-id>/`へ複製する。
- 挿入位置、表示時間、出典は台本と加工済み音声manifestを正本とし、Remotion側へ重複保存しない。
- `index.tsx`の`ContentVisual`は`remotionAssetId`ごとに描画を切り替え、Toolから受け取る相対frameと`durationInFrames`の範囲内でアニメーションする。
- アバター、字幕、背景、章表示、出典表示は作品側に再実装しない。共通コンポーネントは任意に再利用できるが、それだけに限定しない。

## MCP Toolによる制作フェーズ

各Toolの入力、処理、分岐、保存先、検証はToolのスキーマ、説明、実行結果に従う。

| 目的 | MCP Tool |
| --- | --- |
| Google Docs台本から未生成のTTS生データだけを生成する | `youtube-video-pipeline.generate_tts_from_google_doc` |
| 保存済みTTS生データから音声と発話・出典manifestを加工する | `youtube-video-pipeline.process_audio_from_google_doc` |
| 台本のvisual IDと加工済み音声から各内容ビジュアルの確定表示時間を取得する | `youtube-video-pipeline.get_content_visual_timeline` |
| visual IDとRemotion素材IDの対応を指定し、作品素材を内容ビジュアルとして章別MP4またはShortを生成する | `youtube-video-pipeline.render_segment_video` |
| 横動画の章別MP4を連結し、横動画とShortの完成版を配置する | `youtube-video-pipeline.finalize_videos` |
| サムネイル、タイトル、概要欄などの投稿情報を作成する | `youtube-video-pipeline.create_youtube_post_assets` |
| 横動画またはShortをYouTubeへ限定公開で投稿する | `youtube-video-pipeline.upload_youtube_video` |
| 再投稿前に投稿記録と一致する非公開または限定公開動画を削除する | `youtube-video-pipeline.delete_uploaded_youtube_video` |

## 人による確認と進行条件

人の確認はToolで記録せず、制作を次のフェーズへ進めるための会話上の条件として扱う。

1. Image 2.5で内容ビジュアル画像を生成して`source/visuals`へ保存した後、画像を提示して人の確認を待つ。確認されるまでRemotion実装へ進まない。
2. 横動画用とShort用の音声生成後、成果物を提示して人の確認を待つ。音声とRemotion作品素材の両方が揃うまでMP4生成へ進まない。
3. 横動画の全章とShortの分割MP4生成後、固定アバター、章表示、字幕、Ref、内容ビジュアルとアニメーションを確認できる形で提示し、人の確認を待つ。確認されるまで完成版生成へ進まない。
4. 横動画とShortの完成版生成後、成果物を提示して人の最終確認を待つ。確認されるまで投稿用成果物の作成やYouTube投稿へ進まない。

修正指示があった場合は対象フェーズの成果物を再生成し、同じ確認をもう一度行う。
