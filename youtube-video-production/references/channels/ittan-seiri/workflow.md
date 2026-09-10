# 「いったん整理。」制作ワークフロー

## 制作フロー

| 順序 | 工程 | MCP Tool | 使用するTool |
| --- | --- | --- | --- |
| 1 | 横動画用とShort用の台本を作成する | なし | — |
| 2-A | 台本全体と各`visualId`の対象発話から、内容ビジュアルの固定生成パラメータを取得する | あり | `youtube-video-pipeline.prepare_content_visuals_from_google_doc` |
| 2-B | 取得した生成パラメータを使い、Chat/Codex内蔵のGPT Image 2.5で内容ビジュアル画像を生成して保存する | なし | — |
| 2-C | 台本から横動画用とShort用の未生成TTS生データを生成する。2-Aおよび2-Bと並行してよい | あり | `youtube-video-pipeline.generate_tts_from_google_doc` |
| 3 | 2-C完了後、保存済みTTS生データから横動画用とShort用の完成音声とmanifestを加工する。2-Bと並行してよい | あり | `youtube-video-pipeline.process_audio_from_google_doc` |
| 4 | 内容ビジュアル画像と完成音声をまとめて提示し、人の確認を受ける | なし | — |
| 5 | 画像と音声の確認後、各`visualId`の確定表示時間を取得する | あり | `youtube-video-pipeline.get_content_visual_timeline` |
| 6 | 確認済み画像と確定表示時間から、作品固有のRemotionアニメーションを実装する | なし | — |
| 7 | `visualId`と`remotionAssetId`を対応付け、横動画の章別MP4とShortを生成する | あり | `youtube-video-pipeline.render_segment_video` |
| 8 | 生成したすべての分割MP4を提示し、人の確認を受ける | なし | — |
| 9 | 確認済みの章別MP4を連結し、横動画とShortの完成版を配置する | あり | `youtube-video-pipeline.finalize_videos` |
| 10 | 横動画とShortの全体MP4を提示し、人の確認を受ける | なし | — |
| 11 | サムネイル、タイトル、概要欄などの投稿用成果物を作成する | あり | `youtube-video-pipeline.create_youtube_post_assets` |
| 12 | 生成したサムネイルを提示し、人の確認を受ける | なし | — |
| 13 | 横動画またはShortをYouTubeへ限定公開で投稿する | あり | `youtube-video-pipeline.upload_youtube_video` |

再投稿が必要な場合だけ、投稿記録と一致する非公開または限定公開動画を`youtube-video-pipeline.delete_uploaded_youtube_video`で削除してから手順13を再実行する。

Toolを使う工程の入力、処理、分岐、保存先、検証は各Toolのスキーマ、説明、実行結果を正本とする。以下ではToolを使わない工程だけを説明する。

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

## Toolを使わない工程

### 台本作成

[台本テンプレート](script-template.md)を参照し、横動画用とShort用の台本をそれぞれ `source/scripts` にGoogle Docsで作成する。

### Chat/Codexによる内容ビジュアル画像生成

`prepare_content_visuals_from_google_doc`が返す各`generationParameters`を変更せず、Chat/Codex内蔵のGPT Image 2.5で1つずつ生成し、指定された`fileName`と`destinationPath`へ保存する。

### Remotionによる内容ビジュアル実装

画像と確定尺を確認し、内容と構図に合う登場、移動、拡大、強調、場面転換等のアニメーションを作品固有のRemotionコードとして実装する。

- `youtube-remotion-renderer/src/channels/ittan-seiri/videos/<video-id>/`を作り、`index.tsx`を置く。
- Google Driveで確認済みの画像を`youtube-remotion-renderer/public/input/ittan-seiri/<video-id>/`へ複製する。
- 挿入位置、表示時間、出典は台本と加工済み音声manifestを正本とし、Remotion側へ重複保存しない。
- `index.tsx`の`ContentVisual`は`remotionAssetId`ごとに描画を切り替え、Toolから受け取る相対frameと`durationInFrames`の範囲内でアニメーションする。
- アバター、字幕、背景、章表示、出典表示は作品側に再実装しない。共通コンポーネントは任意に再利用できるが、それだけに限定しない。

### 人による確認と進行条件

人の確認はToolで記録せず、制作を次のフェーズへ進めるための会話上の条件として扱う。

1. 内容ビジュアル画像と横動画用・Short用の完成音声が揃った後、両方をまとめて提示して人の確認を待つ。修正指示があれば対象を修正し、両方が確認されるまで確定タイムライン取得とRemotion実装へ進まない。
2. 横動画の全章とShortの分割MP4生成後、固定アバター、章表示、字幕、Ref、内容ビジュアルとアニメーションを確認できる形で提示し、人の確認を待つ。確認されるまで全体MP4生成へ進まない。
3. 横動画とShortの全体MP4生成後、両方を提示して人の確認を待つ。確認されるまで投稿用成果物の作成へ進まない。
4. サムネイル生成後、画像を提示して人の確認を待つ。確認されるまでYouTube投稿へ進まない。

修正指示があった場合は対象フェーズの成果物を再生成し、同じ確認をもう一度行う。
