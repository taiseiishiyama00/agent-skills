---
name: ittan-seiri-video-production
description: 「いったん整理。」の長尺動画・YouTube Shortsの企画、台本、TTS、字幕、素材、Remotion、レビュー、サムネイル、投稿、終了画面、関連動画を新規作成・修正・検証するときに使用する。一般的なYouTube相談や他チャンネルの制作には使用しない。
---

# いったん整理。動画制作

## 目的

「いったん整理。」の動画制作を、Google Driveの作品データ、制作パイプライン、Remotion renderer、YouTubeをまたいで再現可能に進める。

このスキルを制作手順の正本とする。数値はパイプラインの `config/channel.json`、処理はCLIとソースコード、作品固有データはGoogle Driveを正本とし、スキルへ複製しない。

## 対象ワークスペース

通常は次の3領域を使用する。

- `ittan-seiri-video-pipeline`: 工程制御、検証、TTS、字幕、素材台帳、承認、QA、YouTube操作
- `ittan-seiri-video-renderer`: Remotion共通部品と作品固有Composition
- `youtube-production/projects`: Google Drive同期の台本、音声、素材、計画、レビュー、動画、投稿設定

配置を推測で固定しない。パイプラインの検出結果と環境変数を優先し、見つからなければ `doctor --json` のエラーを根拠に停止する。

## 作業開始

1. 対象リポジトリの `git status --short` を確認し、既存の未コミット変更を保護する。
2. パイプラインで次を実行する。

```sh
npm run pipeline -- doctor --json
npm run pipeline -- status <project-id> --json
npm run pipeline -- next <project-id> --json
```

3. `next` が返す未完了工程から進める。正常な成果物を理由なく再生成しない。
4. 依頼内容に応じて、次の参照だけを全文読む。

## 参照の振り分け

- 新規登録、TTS、字幕、素材、同期、レビュー、QA、YouTube Data API操作: [references/pipeline-cli.md](references/pipeline-cli.md)
- 長尺またはShortsの工程全体、次工程の判断: [references/workflow.md](references/workflow.md)
- Shortの台本、縦画面、安全域、サムネイル、公開前後の確認: [references/shorts-production.md](references/shorts-production.md)
- 終了画面、チャンネル登録、Shortの関連動画、専用Edge操作: [references/youtube-studio.md](references/youtube-studio.md)
- Remotion素材境界、共通部品、Composition実装、テスト: [references/remotion-production.md](references/remotion-production.md)

複数領域にまたがる依頼では、該当する参照をすべて読む。関係のない参照は読み込まない。

## 越えてはならない境界

- `paid-api` はユーザーの許可を得るまで実行しない。TTS生成は `--allow-paid-api` なしで呼ばない。
- `human` の承認を推測・代行しない。ユーザーが明示した承認だけを記録する。
- MP4描画前に長尺と初期化済み全Shortsの音声・全シーン画像レビューを生成し、人のレビュー承認を得る。
- 台本、音声、素材、映像実装、レビュー成果物が変わった場合は、古い承認やQAを再利用しない。
- YouTubeへのアップロード、metadata更新、サムネイル設定、公開、Studio保存など外部変更は、対象IDと差分を事前検証し、対応する確認フラグとユーザーの権限範囲を守る。
- 公開状態は依頼なしに変更しない。Studio操作で公開設定へ触れない。
- YouTube Studioの非公開APIを直接呼ばない。表示中の公式UIだけを操作する。
- ユーザーが開いている通常ブラウザを閉じたり、普段使いのプロファイルを直接操作したりしない。
- 秘密鍵、OAuthトークン、Cookie、一時ブラウザプロファイル、`.env.local`、サービスアカウントJSONをGitへ追加しない。

## 制作上の不変条件

- 話題固有素材の原本はGoogle Driveへ置き、`assets register` で出典、権利、用途、ハッシュを登録する。
- アバター、共通BGM、ジングル、効果音など複数作品で使う素材だけをrendererの `public/assets` へ置く。
- `public/input/<projectId>` と `src/generated` は同期コピーであり、直接編集しない。
- 素材追加とComposition実装を別工程にする。
- 字幕時刻は `caption-plan.json` のcueを唯一の時刻源とする。
- 発話の `referenceIds` と `video-plan.json` のリファレンス定義を一致させる。
- 意味の異なる発話へ同じ汎用図解を使い回さず、レビュー静止画だけでもvisual IDごとの差が分かるようにする。
- 作品固有実装は `src/videos/<projectId>` へ閉じ、共通化できる表現だけを `src/framework` へ置く。

## 変更後の確認

1. データや工程を変更したら `status <project-id> --json` を再実行する。
2. コードを変更したら対象リポジトリの `npm run check` を実行する。
3. 描画物は用途に合う実寸とスマートフォン相当の縮小表示で目視確認する。
4. YouTubeへ変更したらAPI状態だけで完了にせず、再読込後のStudioまたは実際の配信画像・再生画面で反映を確認する。
5. 一時ログ、診断画像、一時ブラウザプロファイルを安全に削除し、秘密情報や生成物がGit差分へ入っていないことを確認する。
