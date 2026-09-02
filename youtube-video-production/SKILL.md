---
name: youtube-video-production
description: 設定済みYouTubeチャンネルの長尺動画・Shortsについて、企画、台本、TTS、字幕、素材、Remotion、レビュー、サムネイル、投稿、終了画面、関連動画を新規作成・修正・検証するときに使用する。一般的なYouTube相談や、制作基盤に登録されていない動画には使用しない。
---

# YouTube動画制作

## 目的

複数のYouTubeチャンネルを、Google Driveの作品データ、共通制作パイプライン、Remotion renderer、YouTubeをまたいで再現可能かつ安全に制作する。

このスキルは全チャンネル共通の制作手順だけを扱う。チャンネル名、話者、TTS、字幕、安全域、音声、描画、QAなどの具体値は `youtube-video-pipeline/config/channels/<channel-id>.json`、作品固有値はGoogle Driveの作品データを正本とし、スキルへ複製しない。

この `SKILL.md` をユーザー向けルールの正本とする。参照文書、CLI、実装契約、テストは処理を機械化するための詳細であり、このスキルと矛盾する規則や、このスキルより強い承認・レビュー要件を追加してはならない。矛盾を見つけた場合は実装側をこのスキルへ合わせる。

## 対象ワークスペース

- `youtube-video-pipeline`: 工程制御、検証、TTS、字幕、素材台帳、承認、QA、YouTube操作
- `youtube-remotion-renderer`: 技術共通、動画形式、チャンネル、作品ごとのRemotion実装
- `youtube-production/common`: 複数チャンネルが同一条件で使う制作資産
- `youtube-production/channels/<channel-id>/assets`: チャンネル固有のブランド資産
- `youtube-production/channels/<channel-id>/projects`: 作品固有の台本、音声、素材、計画、レビュー、動画、投稿設定

配置を推測で固定しない。パイプラインの検出結果と環境変数を優先し、見つからなければ `doctor --json` のエラーを根拠に停止する。

## 作業開始

1. ユーザーの依頼または作品の `project.json` から `<channel-id>` と `<project-id>` を確定する。
2. 対象リポジトリの `git status --short` を確認し、既存の未コミット変更を保護する。
3. パイプラインで次を実行する。

```sh
npm run pipeline -- --channel <channel-id> doctor --json
npm run pipeline -- --channel <channel-id> status <project-id> --json
npm run pipeline -- --channel <channel-id> next <project-id> --json
```

4. `project.json` の `channelId` と選択したprofileが一致することを確認する。
5. `next` が返す未完了工程から進め、正常な成果物を理由なく再生成しない。
6. 依頼内容に応じて、次の参照だけを全文読む。

## 参照の振り分け

- 新規登録、TTS、字幕、素材、同期、レビュー、QA、YouTube Data API操作: [references/pipeline-cli.md](references/pipeline-cli.md)
- 長尺またはShortsの工程全体、次工程の判断: [references/workflow.md](references/workflow.md)
- 長尺・Shorts台本のGoogle Docs共同編集、コメント反映、`台本.md` 同期: [references/script-collaboration.md](references/script-collaboration.md)
- 社会・経済・テクノロジーなどのニュース解説台本の調査、フック、TVコント、10分以内の構成、生活への接続: [references/news-explainer-script.md](references/news-explainer-script.md)
- Shortの台本、縦画面、安全域、サムネイル、公開前後の確認: [references/shorts-production.md](references/shorts-production.md)
- 終了画面、チャンネル登録、Shortの関連動画、専用Edge操作: [references/youtube-studio.md](references/youtube-studio.md)
- Remotionの所有境界、Composition実装、テスト: [references/remotion-production.md](references/remotion-production.md)

複数領域にまたがる依頼では該当する参照をすべて読み、関係のない参照は読み込まない。

## 所有境界

配置は「最も狭い所有者」を選ぶ。

- `common`: 2つ以上のチャンネルが、同じ契約・権利・内容で共有する技術または資産
- `format`: 会話解説、ニュース、インタビューなど、複数チャンネルで再利用できる動画形式の契約と表現
- `channel`: ロゴ、色、アバター、話者、語調など、1チャンネルが所有するブランド具体
- `project`: 題材、台本、出典、画像、Compositionなど、1作品だけの具体

将来再利用できそうという理由だけで上位へ置かない。2つ目の利用先が現れ、責務と権利条件が一致してから共通へ昇格する。下位層から上位層への依存は許可するが、`common` や `format` から特定チャンネル・作品へ依存させない。

## 3段階の人間承認ゲート前の共通品質ゲート

- 人の承認を得る制作成果物は、`台本`、`分割レビューMP4`、`全編MP4` の3種類だけとし、この順序を守る。音声、字幕、素材、サムネイル、投稿設定などは制作過程であり、別の承認ゲートにしない。
- この3種類を人へ渡す前に、作成者以外のレビューエージェントを原則1名置く。第三者目線で最低限の品質を確認し、目立つ欠落、破綻、違和感などのネガティブ要素を取り除くことだけを求める。
- blocker、major、または明白な品質不足が見つかった場合は修正し、同じレビューエージェントで対象成果物だけを再確認する。レビュー結果を専用成果物として保存する必要はない。
- エージェントレビューは人の承認を代行しない。ShortsのレビューMP4と投稿用全編MP4が同一なら、同じ動画へ重複した人間承認を求めない。

## 越えてはならない境界

- 正常フローで初めてTTS音声を生成するときは、都度の確認なしで実行する。既存音声を有料APIで再生成する必要がある場合だけ停止して許可を取り、許可後に `--allow-paid-api` を付ける。課金を伴わないキャッシュ再利用では確認を求めない。
- `human` の承認を推測・代行しない。ユーザーが明示した承認だけを記録する。
- 映像レビューの承認対象はMP4だけにする。音声単体、全シーン静止画、contact sheet、motion clip、旧preview動画を別の承認成果物として生成または要求しない。
- 長尺は章境界ごとの連続MP4へ分け、初期化済みShortsは1本ずつ全編MP4を作る。分割本数に固定上限を設けない。
- 分割MP4はsegmentごとに人が確認して個別承認する。全segmentの最新hashが承認されるまで全編MP4を描画しない。
- 区間固有の修正は指摘対象segmentだけを再描画して再承認する。共通コンポーネント、全体構成、音声、字幕時刻、共通素材など複数segmentへ影響し得る修正は全segmentを再描画して再承認する。影響範囲を判定できない場合も全segmentを対象にする。
- 成果物の変更に伴う承認の失効範囲はパイプラインで機械的に判定し、古い承認を別の成果物へ流用しない。
- YouTubeへの変更前に、OAuthで認証された実チャンネルIDとprofileの `youtubeChannelId` が一致することを確認する。不一致時は操作しない。
- YouTubeへのアップロード、metadata更新、サムネイル設定、公開、Studio保存は、対象IDと差分を事前検証し、対応する確認フラグとユーザーの権限範囲を守る。
- 公開状態は依頼なしに変更しない。Studio操作で公開設定へ触れない。
- YouTube Studioの非公開APIを直接呼ばず、表示中の公式UIだけを操作する。
- ユーザーが開いている通常ブラウザを閉じたり、普段使いのプロファイルを直接操作したりしない。
- 秘密鍵、OAuthトークン、Cookie、一時ブラウザプロファイル、`.env.local`、サービスアカウントJSONをGitへ追加しない。

## 変更後の確認

1. データや工程を変更したら `status <project-id> --json` を再実行する。
2. コードを変更したら対象リポジトリの `npm run check` を実行する。
3. 描画物は用途に合う実寸とスマートフォン相当の縮小表示で目視確認する。
4. YouTubeへ変更したらAPI状態だけで完了にせず、再読込後のStudioまたは実際の配信画像・再生画面で反映を確認する。
5. 一時ログ、診断画像、一時ブラウザプロファイルを安全に削除し、秘密情報や生成物がGit差分へ入っていないことを確認する。
