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

- 横動画用ショート動画用それぞれの台本を `source/scripts` にGoogle Docsで作成する。
- 台本は人間主体で作成する。それ以外の特定のフローは設けない。
- 見出し1を動画タイトルにする。
- 横動画は見出し2を `chapter: <chapter-id> | <表示名>` とし、`skit`、`opening`、`chapter-01` から始まる連番、`summary` の順に置く。
- Shortには章見出しを置かない。
- 発話は標準テキストの段落ごとに `<speaker-id>: <発話本文>` と書く。speaker-idはチャンネル設定の `host` または `explainer` を使う。

## 音声生成フェーズ

MCP Tool: `youtube-video-pipeline.generate_audio_from_google_doc`

- 入力は `channelId`、`documentUrl`、`target`、`allowPaidGeneration` とする。`documentUrl` は `source/scripts` 直下のGoogle Docs URL、`target` は `long` または `short` とする。
- まず `allowPaidGeneration: false` で呼び出し、保存済みキャッシュだけで完了できるか、未生成グループに課金が必要かを確認する。
- `payment-required` が返った場合は課金が発生することをユーザーへ明示する。ユーザーが生成を指示した後だけ、同じ入力を `allowPaidGeneration: true` にして再実行する。
- 横動画は各発話を句読点・記号・空白を除いて360文字以内とし、章をまたがず、同じ数え方による合計360文字以内で発話をグルーピングする。Shortは章分けせず1グループとする。
- ToolはMFAで発話境界を特定し、横動画は章平均、Shortは全体平均で最低発話速度を満たす場合だけ速くする。遅くする補正は行わない。
- 話者が切り替わる位置にだけ0.5秒の無音を挿入する。

- 横動画とShortのTTS音声は、それぞれ `source/audio/long` と `source/audio/short` に保存する。
- 有料APIが返した音声は、アラインメント、分割、速度補正などの後処理より先に `source/audio/<対象>/.segments` へ保存する。後工程が失敗しても削除せず、再実行時に再利用する。
- 章単位の完成音声と、入力・生成音声のハッシュおよび再利用元を記録した `manifest.json` も `source/audio/<対象>` に残す。
- 章単位の完成音声を連結した `full.wav` も `source/audio/<対象>` に残す。
- 同じ入力、モデル、音声、生成指示に対応する保存済み音声がある場合は、有料APIを呼び直さず保存済み音声を使う。再生成は入力または設定を変えた場合に限り、課金が発生することを明示して実行する。

## MP4作成フェーズ

- 横動画は章ごとに分けたMP4を作成する。
- Shortは1つのMP4として作成する。
- 完成した各MP4を、作成者とは別のエージェントが品質レビューする。
- 品質レビュー後、人間がレビューできるように `source/videos` へ置く。
- 人間のレビューに応じて、横動画は章ごとに作り直す。

## MP4連結フェーズ

- 人間レビュー済みの横動画の章別MP4を連結し、1つのMP4にする。
- 連結した横動画を、作成者とは別のエージェントが品質レビューする。
- 品質レビュー後、人間がレビューできるように `output/long/video.mp4` へ置く。
- 人間レビュー済みのShortを `output/short/video.mp4` へ置く。

## 関連情報作成フェーズ

- サムネイル、タイトル、概要など、投稿に必要な情報を作成する。
- 人間がレビューできるように `output` へ置く。

## 投稿フェーズ

- 横動画とShortをYouTubeへ投稿する。
- 公開状態は限定公開にする。公開への変更は人間が主導する。
- サムネイルなどの投稿情報を設定する。
- Shortの関連動画に、同じ作品の横動画を設定する。
- 横動画のエンディングの最後12秒に、前回の横動画へのリンクとチャンネル登録ボタンを設定する。
