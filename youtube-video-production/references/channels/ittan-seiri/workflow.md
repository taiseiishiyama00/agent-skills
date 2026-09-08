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
- Shortは見出し2を `segment: skit | 冒頭コント`、`segment: summary | 解説サマリ` の順に置く。見出しは区間判定だけに使い、映像のインサートにはしない。
- 発話は標準テキストの段落ごとに `<speaker-id>: <発話本文>` と書く。speaker-idはチャンネル設定の `host` または `explainer` を使う。
- 横動画の通常章では `explainer:` の標準テキスト段落1つを1回答、`summary` では `host:` の標準テキスト段落1つを1要点として扱う。シーン設計は対象段落ごとに対応する内容ビジュアルを持つ。
- Shortの `summary` では `explainer:` の標準テキスト段落1つを1回答として扱う。シーン設計は解説サマリの先頭と対象段落ごとに対応する内容ビジュアルを持つ。
- Short末尾の固定CTAはGoogle Docsへ書かず、チャンネル設定から音声生成時に自動追加する。

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
- `manifest.json` には速度補正と話者間無音を反映した発話・単語・音素の開始終了時刻を保存し、映像、字幕、5母音と閉口によるリップシンクの唯一の同期元とする。
- 横動画は章をまたいで話者が切り替わる場合も、前章の末尾へ0.5秒の無音を入れる。
- 同じ入力、モデル、音声、生成指示に対応する保存済み音声がある場合は、有料APIを呼び直さず保存済み音声を使う。再生成は入力または設定を変えた場合に限り、課金が発生することを明示して実行する。

## MP4作成フェーズ

MCP Tool: `youtube-video-pipeline.render_video_from_scene_plan`

- 入力は `channelId`、`projectSource`、`target`、`chapterId`、`scenePlan` とする。`projectSource` は取得元の種別と場所を持ち、初版はGoogle Driveの作品フォルダURLへ対応する。`chapterId` は横動画で必須、Shortでは指定しない。
- 横動画は1章、Shortは全編のシーン設計JSONを1回の呼び出しで渡す。Toolは検証済みJSONを `.pipeline` へ保存し、一時TSXと一時素材からRemotionを実行する。作品固有TSXはrendererへ残さない。
- Toolは `source/audio/<対象>/manifest.json` とWAV、`source/references.json`、`source/assets/manifest.json` を作品フォルダから解決する。
- 独自取得素材は `source/assets` からの相対パスで指定し、同じパスの `sourceUrl`、`rights`、`rightsVerified: true` が素材manifestになければ停止する。外部動画の音声は使用しない。
- Google Material SymbolsとGoogle Noto Emojiは固定バージョンの全正式IDを指定できる。Noto EmojiはGoogle公式リポジトリの固定コミットから実行時に一時取得し、取得元とライセンスを実行記録へ残した後、一時ファイルを削除する。
- 内容ビジュアルは登録済みの宣言的コンポーネントだけを使用し、任意のHTML、React、CSS、絶対座標を入力として受け付けない。内容ビジュアル以外の配置とサイズはチャンネル共通コンポーネントで固定する。
- `skit` は通常レイアウトを基礎とし、ヘッダーへシーン設計の `topic` から「これは○○の解説動画です。」と表示して出典を表示しない。
- 横動画の `opening` は固定オープニング72フレームの後に音声と内容ビジュアルを表示する。通常章と `summary` は章タイトル75フレームの後に表示し、`summary` の末尾には固定エンディング360フレームを含める。
- 横動画の本編章と `summary` の各内容ビジュアルには1件以上の出典IDを必須とする。`skit` は出典を禁止し、`opening` は出典なしを許可する。
- Shortはコント中に「これは○○の解説動画です。」を表示して出典を表示しない。インサートを挟まず解説サマリへ移り、サマリ開始時から内容ビジュアルと1件以上の出典を表示する。固定CTAでは直前の表示を維持する。
- Toolは音素時刻を使い、発話中の話者だけ正式Blenderアバターを日本語5母音と閉口の口形でリップシンクする。
- 自動QAに失敗した生成物は破棄し、既存MP4を変更しない。合格した再生成動画は同じ固定ファイル名の既存MP4を置き換える。

- 横動画は章ごとに分けたMP4を作成する。
- Shortは1つのMP4として作成する。
- 自動QA後、人間がレビューできるように `source/videos` へ置く。
- 人間のレビューに応じて、横動画は章ごとに作り直す。

## MP4連結フェーズ

- 人間レビュー済みの横動画の章別MP4を連結し、1つのMP4にする。
- 連結した横動画を自動QA後、人間がレビューできるように `output/long/video.mp4` へ置く。
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
