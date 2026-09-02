# 制作パイプラインCLI

## 責務と正本

- `youtube-video-pipeline`: 工程制御、入力検証、TTS、字幕アラインメント、素材台帳、Remotion同期・描画、QA、承認ゲート、YouTube Data API操作
- `youtube-remotion-renderer`: 技術共通、形式共通、チャンネル固有、作品固有に分離したRemotion実装
- Google Driveの `common`: 複数チャンネルが同じ条件で共有する制作資産
- Google Driveの `channels/<channel-id>/assets`: チャンネル固有資産
- Google Driveの `channels/<channel-id>/projects`: 台本、WAV、話題固有素材、設計JSON、動画、実行状態、投稿設定
- rendererの `public/assets/common`: 全チャンネル共通素材
- rendererの `public/assets/channels/<channel-id>`: アバター、ロゴなどチャンネル固有素材
- rendererの `public/input/<channel-id>/<projectId>`: 描画時に同期される作品固有素材。原本ではない

共通の数値は `config/channels/<channel-id>.json`、処理はCLIと `src/`、作品固有値はGoogle Drive側の作品ファイルを正本とする。

## セットアップと診断

Node.jsはリポジトリの要件を満たす版を使う。

```sh
npm install
npm run check
npm run pipeline -- --channel <channel-id> doctor --json
```

通常はpipeline、renderer、Google Drive同期領域を同じ親ディレクトリから検出する。配置が異なる場合は、リポジトリの現在の環境変数仕様をREADMEまたはソースで確認する。秘密情報をGit管理ファイルへ書かない。

既存作品では毎回次から始める。

```sh
npm run pipeline -- --channel <channel-id> doctor --json
npm run pipeline -- --channel <channel-id> status <project-id> --json
npm run pipeline -- --channel <channel-id> next <project-id> --json
```

`next --json` は工程を `deterministic`、`paid-api`、`ai`、`human` に分類する。有料APIと人の承認を自動で越えない。

## 作品登録

```sh
npm run pipeline -- --channel <channel-id> project init <project-id> \
  --directory <Drive上の作品ディレクトリ名> \
  --title <動画タイトル> \
  --format <format-id> \
  --composition <Remotion Composition ID> \
  --entry src/channels/<channel-id>/videos/<project-id>/<Component>.tsx
```

既存作品は `project adopt` で登録する。登録後に `status` と `next` を確認する。

## 音声

```sh
npm run pipeline -- --channel <channel-id> tts dry-run <project-id>
npm run pipeline -- --channel <channel-id> tts generate <project-id>
```

- 初回生成は正常フローとして確認なしで実行する。既存音声を有料APIで再生成する必要がある場合だけCLIが停止するため、ユーザーの許可後に `--allow-paid-api` を付けて再実行する。
- profileの既定話者以外が登場する場合は、作品の `tts-config.json` に安定した話者ID、台本名、Voiceを定義する。
- TTS側の話者上限に合わせ、発話順を壊さず最大話者数以内の連続区間へ分ける。
- 台本の独立行にある角括弧の時間インサートは読み上げず、次の発話を新しいTTS区間にする。
- 連続生成blockを使う場合は入力上限を事前確認し、生成rawをhash付きで保全してから章境界を確定する。
- Google Drive上の元WAVは変更せず、renderer用コピーだけをチャンネル設定の方式で全章一貫して正規化する。
- 同じ音声を再生成して重複課金しない。manifest、入力hash、quarantineの再利用可否を先に確認する。

## 字幕同期

台本から一度に表示する意味チャンクを `caption-plan.json` に作り、MFAで各チャンクの先頭を単語時刻へ合わせる。

```sh
npm run pipeline -- --channel <channel-id> captions run <project-id>
```

分割実行:

```sh
npm run pipeline -- --channel <channel-id> captions prepare <project-id>
npm run pipeline -- --channel <channel-id> captions audit <project-id> --textgrids <directory>
npm run pipeline -- --channel <channel-id> captions apply <project-id> --textgrids <directory>
```

字幕時刻を文字数比例や発話全体の推定配分へ戻さない。完成品では同時に1cueだけを表示する。

## 話題固有素材

素材原本をGoogle Driveの作品ディレクトリへ保存してから、権利、出典、用途と一緒に登録する。

```sh
npm run pipeline -- --channel <channel-id> assets register <project-id> \
  --id topic-image-01 \
  --type image \
  --source source/images/example.jpg \
  --rights quotation \
  --category topic \
  --renderer-path input/<channel-id>/<project-id>/topic/example.jpg \
  --reference-id R01 \
  --source-url https://example.com/source \
  --usage "R01の説明時に引用表示"
```

scopeは、作品固有なら `project`、チャンネル固有なら `channel`、複数チャンネル共通なら `common` を指定する。権利区分はCLIが受け付ける現在の値を使う。企業、製品、組織が主題なら公式一次ソースのロゴ、アイコン、画面素材を優先的に検討し、使用前に `sourceUrl` と `rights` を登録する。登録後のファイル変更はhash検査で停止させる。

## Remotion同期と実装契約

素材追加とComposition実装は別工程にする。

```sh
npm run pipeline -- --channel <channel-id> assets validate <project-id> --json
npm run pipeline -- --channel <channel-id> remotion sync <project-id> --json
npm run pipeline -- --channel <channel-id> remotion sync <project-id> --plans-only --json
npm run pipeline -- --channel <channel-id> remotion task <project-id> --json
```

`remotion sync` は作品素材、正規化WAV、映像計画、字幕計画をrendererのGit管理外領域へ同期する。音声生成前に実装する場合だけ `--plans-only` を使う。実装時は `remotion task --json` の契約に従う。

## レビュー、描画、QA、承認

CLIの承認状態は、制作成果物の `台本`、`分割レビューMP4`、`全編MP4` という3ゲートに対応させる。サムネイル、投稿文、投稿設定を新しい承認ゲートとして追加しない。台本ゲートは [script-collaboration.md](script-collaboration.md)、各ゲート前の独立レビューは `SKILL.md` の共通品質ゲートに従う。

```sh
npm run pipeline -- --channel <channel-id> review generate <project-id>
npm run pipeline -- --channel <channel-id> approve <project-id> review --segment <segment-id>
npm run pipeline -- --channel <channel-id> review generate <project-id> --segment <segment-id>
npm run pipeline -- --channel <channel-id> remotion full <project-id>
npm run pipeline -- --channel <channel-id> qa <project-id>
npm run pipeline -- --channel <channel-id> approve <project-id> final
```

- `review generate` は横動画を章境界ごとの連続MP4へ分け、初期化済みShortを全編MP4として生成する。分割本数に固定上限を設けない。
- 初回または横断変更時はオプションなしで全segmentを生成する。局所修正時だけ `--segment <segment-id>` で該当MP4を再生成する。影響範囲が不明なら全生成する。
- 人へ渡す前に、最新のMP4と入力hashで分割レビューMP4の共通品質ゲートを通す。
- 人が各MP4を確認し、`approve ... review --segment <segment-id>` で個別承認する。全MP4を一度に確認した場合だけ `--all` を使用できる。
- 各承認はsegment MP4のSHA-256へ結び付く。部分再生成では変更segmentの承認だけが失効し、共通部品、全体構成、音声、字幕時刻、共通素材などの横断変更では全segmentを再生成して全承認を取り直す。
- 全segmentが最新hashで承認されるまで `remotion full` と通常のShort renderを実行しない。
- `remotion full` とShort renderの後はQAを実行し、最新の全編MP4で共通品質ゲートを通してから `approve ... final` を記録する。Shortの投稿用全編MP4が承認済みレビューMP4と同一hashなら、同一成果物への重複承認を要求しない。
- 音声単体、全シーン静止画、contact sheet、motion clip、旧preview動画を生成・承認する旧レビュー工程は存在しない。
- QAも全編動画のhashへ結び付け、別の動画へ流用しない。

## 作品データ

作品構成は `SKILL.md` の「Google Driveの作品構成」を正本とし、`project init` で機械的に作成する。人が扱う入力は `source`、公開用成果物は `output`、計画・台帳・レビュー・QA・承認状態は `.pipeline` に分ける。内部ファイルを手作業で移動・改名せず、秘密鍵は作品ディレクトリへ置かない。

## Shorts CLI

```sh
npm run pipeline -- --channel <channel-id> shorts init <project-id> <short-id> \
  --title <short-title> \
  --composition <Remotion Composition ID> \
  --entry src/channels/<channel-id>/videos/<project-id>/<ShortComponent>.tsx

npm run pipeline -- --channel <channel-id> shorts task <project-id> <short-id> --json
npm run pipeline -- --channel <channel-id> shorts tts <project-id> <short-id> --dry-run
npm run pipeline -- --channel <channel-id> shorts tts <project-id> <short-id>
npm run pipeline -- --channel <channel-id> shorts captions <project-id> <short-id>
npm run pipeline -- --channel <channel-id> shorts sync <project-id> <short-id>
npm run pipeline -- --channel <channel-id> shorts sync <project-id> <short-id> --plans-only
npm run pipeline -- --channel <channel-id> shorts still <project-id> <short-id> --frame <frame>
npm run pipeline -- --channel <channel-id> shorts render <project-id> <short-id>
npm run pipeline -- --channel <channel-id> shorts qa <project-id> <short-id> --json
```

`<short-id>` は内部識別子であり、Drive上にID別ディレクトリは作らない。1作品へ初期化できるShortは1本だけとする。Short固有の判断は `shorts-production.md` を併せて読む。

## YouTube Data API

OAuthクライアントJSONと認証トークンはGit管理外のsecrets領域へ置く。トークンの既定名は `youtube-oauth-token-<channel-id>.json` とし、Google側で失効した場合だけ再認証する。

```sh
npm run pipeline -- --channel <channel-id> youtube auth
npm run pipeline -- --channel <channel-id> youtube validate <project-id> long --json
npm run pipeline -- --channel <channel-id> youtube upload <project-id> long --confirm-upload
npm run pipeline -- --channel <channel-id> youtube recover <project-id> long --confirm-upload
npm run pipeline -- --channel <channel-id> youtube metadata <project-id> long --confirm-upload
npm run pipeline -- --channel <channel-id> youtube thumbnail <project-id> long --confirm-upload
npm run pipeline -- --channel <channel-id> youtube status <project-id> long --json
npm run pipeline -- --channel <channel-id> youtube publish <project-id> long --confirm-publish
```

対象には `long` または作品で初期化済みのShortを指定する。

- 先に `youtube validate` を実行し、動画、投稿文、サムネイル、文字数、タグ、公開設定を外部変更なしで確認する。
- 認証後と各YouTube API操作前に、profileの `youtubeChannelId` とOAuthで取得した実チャンネルIDを照合する。不一致ならアップロードや更新を行わない。
- アップロード時の公開設定は作品の `youtube-post.json` に `private` または `unlisted` を指定する。直接公開は安全検証に従う。
- `metadata` はタイトル、概要欄、カテゴリ、タグを投稿済み動画へ再同期する。
- `thumbnail` は設定ファイルの画像を投稿済み動画へ設定する。
- `recover` は動画本体成功後の追加設定失敗から復旧する場合に使い、同名動画の二重投稿を防ぐ。
- 公開は最終確認後にだけ `publish --confirm-publish` で行う。
- 終了画面とShortの関連動画は公開APIで設定せず、`youtube-studio.md` に従う。

## 設定変更

動画ごとに同じ数値を複製せず、`config/channels/<channel-id>.json` を変更する。TTS、字幕、安全域、音声正規化、描画、インサート、QA、素材ポリシーが対象になる。作品固有計画が共通値と一致しない場合は `status` の報告を確認する。
