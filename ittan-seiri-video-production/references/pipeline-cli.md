# 制作パイプラインCLI

## 責務と正本

- `ittan-seiri-video-pipeline`: 工程制御、入力検証、TTS、字幕アラインメント、素材台帳、Remotion同期・描画、QA、承認ゲート、YouTube Data API操作
- `ittan-seiri-video-renderer`: 再利用可能なRemotion部品と作品固有Composition
- Google Driveの制作領域: 台本、WAV、話題固有素材、設計JSON、動画、実行状態、投稿設定
- rendererの `public/assets`: アバター、BGM、効果音など複数作品で使う共通素材
- rendererの `public/input/<projectId>`: 描画時に同期される作品固有素材。原本ではない

共通の数値は `config/channel.json`、処理はCLIと `src/`、作品固有値はGoogle Drive側の作品ファイルを正本とする。

## セットアップと診断

Node.jsはリポジトリの要件を満たす版を使う。

```sh
npm install
npm run check
npm run pipeline -- doctor --json
```

通常はpipeline、renderer、Google Drive同期領域を同じ親ディレクトリから検出する。配置が異なる場合は、リポジトリの現在の環境変数仕様をREADMEまたはソースで確認する。秘密情報をGit管理ファイルへ書かない。

既存作品では毎回次から始める。

```sh
npm run pipeline -- doctor --json
npm run pipeline -- status <project-id> --json
npm run pipeline -- next <project-id> --json
```

`next --json` は工程を `deterministic`、`paid-api`、`ai`、`human` に分類する。有料APIと人の承認を自動で越えない。

## 作品登録

```sh
npm run pipeline -- project init <project-id> \
  --directory <Drive上の作品ディレクトリ名> \
  --title <動画タイトル> \
  --composition <Remotion Composition ID> \
  --entry src/videos/<project-id>/<Component>.tsx
```

既存作品は `project adopt` で登録する。登録後に `status` と `next` を確認する。

## 音声

```sh
npm run pipeline -- tts dry-run <project-id>
npm run pipeline -- tts generate <project-id> --allow-paid-api
```

- 有料生成前に必ず `tts dry-run` で話者、区間、リクエスト数、入力サイズを確認する。
- 通常の進行役・解説役以外が登場する場合は、作品の `tts-config.json` に安定した話者ID、台本名、Voiceを定義する。
- TTS側の話者上限に合わせ、発話順を壊さず最大話者数以内の連続区間へ分ける。
- 台本の独立行にある角括弧の時間インサートは読み上げず、次の発話を新しいTTS区間にする。
- 連続生成blockを使う場合は入力上限を事前確認し、生成rawをhash付きで保全してから章境界を確定する。
- Google Drive上の元WAVは変更せず、renderer用コピーだけをチャンネル設定の方式で全章一貫して正規化する。
- 同じ音声を再生成して重複課金しない。manifest、入力hash、quarantineの再利用可否を先に確認する。

## 字幕同期

台本から一度に表示する意味チャンクを `caption-plan.json` に作り、MFAで各チャンクの先頭を単語時刻へ合わせる。

```sh
npm run pipeline -- captions run <project-id>
```

分割実行:

```sh
npm run pipeline -- captions prepare <project-id>
npm run pipeline -- captions audit <project-id> --textgrids <directory>
npm run pipeline -- captions apply <project-id> --textgrids <directory>
```

字幕時刻を文字数比例や発話全体の推定配分へ戻さない。完成品では同時に1cueだけを表示する。

## 話題固有素材

素材原本をGoogle Driveの作品ディレクトリへ保存してから、権利、出典、用途と一緒に登録する。

```sh
npm run pipeline -- assets register <project-id> \
  --id topic-image-01 \
  --type image \
  --source 素材/official/example.jpg \
  --rights quotation \
  --category topic \
  --renderer-path input/<project-id>/topic/example.jpg \
  --reference-id R01 \
  --source-url https://example.com/source \
  --usage "R01の説明時に引用表示"
```

権利区分はCLIが受け付ける現在の値を使う。企業、製品、組織が主題なら公式一次ソースのロゴ、アイコン、画面素材を優先的に検討し、使用前に `sourceUrl` と `rights` を登録する。登録後のファイル変更はhash検査で停止させる。

## Remotion同期と実装契約

素材追加とComposition実装は別工程にする。

```sh
npm run pipeline -- assets validate <project-id> --json
npm run pipeline -- remotion sync <project-id> --json
npm run pipeline -- remotion sync <project-id> --plans-only --json
npm run pipeline -- remotion task <project-id> --json
```

`remotion sync` は作品素材、正規化WAV、映像計画、字幕計画をrendererのGit管理外領域へ同期する。音声生成前に実装する場合だけ `--plans-only` を使う。実装時は `remotion task --json` の契約に従う。

## レビュー、描画、QA、承認

```sh
npm run pipeline -- review generate <project-id>
npm run pipeline -- approve <project-id> review
npm run pipeline -- remotion preview <project-id>
npm run pipeline -- approve <project-id> preview
npm run pipeline -- remotion full <project-id>
npm run pipeline -- qa <project-id>
npm run pipeline -- approve <project-id> final
```

- `review generate` は長尺と初期化済み全Shortsを同期し、音声と全シーン静止画をGoogle Driveへ生成する。
- 人が生成物を確認し、明示的に承認するまでpreview、full、Short renderを実行しない。
- 承認は成果物のSHA-256へ結び付く。台本、音声、素材、映像実装、レビュー素材、動画の変更後に古い承認を再利用しない。
- QAも全編動画のhashへ結び付け、別の動画へ流用しない。

## 作品データ

各作品では少なくとも次を管理する。

- `project.json`: 作品ID、Composition、出力名
- `台本.md`: TTS入力
- `tts-config.json`: 作品へ適用する音声設定
- `音声/manifest.json`: 章WAV、master、入力hash
- `caption-plan.json`: 意味チャンクとMFA時刻
- `video-plan.json`: 映像、発話、リファレンス、素材参照、エンディング尺
- `asset-manifest.json`: 出典、権利、用途、hash
- `素材/レビュー`: 人が確認する音声、全シーン画像、対応表、manifest、index
- `.pipeline/state.json`: 実行履歴と承認
- `.pipeline/qa-report.json`: 全編動画に紐付くQA結果
- `投稿/youtube-post.json`: 長尺・Shortの投稿文、公開設定、サムネイル、投稿ID、Studio操作対象

秘密鍵は作品ディレクトリへ置かない。

## Shorts CLI

```sh
npm run pipeline -- shorts init <project-id> <short-id> \
  --title <short-title> \
  --composition <Remotion Composition ID> \
  --entry src/videos/<project-id>/<ShortComponent>.tsx

npm run pipeline -- shorts task <project-id> <short-id> --json
npm run pipeline -- shorts tts <project-id> <short-id> --dry-run
npm run pipeline -- shorts tts <project-id> <short-id> --allow-paid-api
npm run pipeline -- shorts captions <project-id> <short-id>
npm run pipeline -- shorts sync <project-id> <short-id>
npm run pipeline -- shorts sync <project-id> <short-id> --plans-only
npm run pipeline -- shorts still <project-id> <short-id> --frame <frame>
npm run pipeline -- shorts render <project-id> <short-id>
npm run pipeline -- shorts qa <project-id> <short-id> --json
```

Shorts固有の判断は `shorts-production.md` を併せて読む。

## YouTube Data API

OAuthクライアントJSONと認証トークンはGit管理外のsecrets領域へ置く。Google側でトークンが失効した場合だけ再認証する。

```sh
npm run pipeline -- youtube auth
npm run pipeline -- youtube validate <project-id> long --json
npm run pipeline -- youtube upload <project-id> long --confirm-upload
npm run pipeline -- youtube recover <project-id> long --confirm-upload
npm run pipeline -- youtube metadata <project-id> long --confirm-upload
npm run pipeline -- youtube thumbnail <project-id> long --confirm-upload
npm run pipeline -- youtube status <project-id> long --json
npm run pipeline -- youtube publish <project-id> long --confirm-publish
```

対象には `long` または作品で初期化済みのShortを指定する。

- 先に `youtube validate` を実行し、動画、投稿文、サムネイル、文字数、タグ、公開設定を外部変更なしで確認する。
- アップロード時の公開設定は作品の `youtube-post.json` に `private` または `unlisted` を指定する。直接公開は安全検証に従う。
- `metadata` はタイトル、概要欄、カテゴリ、タグを投稿済み動画へ再同期する。
- `thumbnail` は設定ファイルの画像を投稿済み動画へ設定する。
- `recover` は動画本体成功後の追加設定失敗から復旧する場合に使い、同名動画の二重投稿を防ぐ。
- 公開は最終確認後にだけ `publish --confirm-publish` で行う。
- 終了画面とShortの関連動画は公開APIで設定せず、`youtube-studio.md` に従う。

## 設定変更

動画ごとに同じ数値を複製せず、`config/channel.json` を変更する。TTS、字幕、安全域、音声正規化、描画、インサート、QA、素材ポリシーが対象になる。作品固有計画が共通値と一致しない場合は `status` の報告を確認する。
