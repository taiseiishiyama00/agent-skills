---
name: youtube-video-production
description: 設定済みYouTubeチャンネルの長尺動画・Shortsについて、企画、台本、TTS、字幕、素材、Remotion、レビュー、サムネイル、投稿、終了画面、関連動画を新規作成・修正・検証するときに使用する。一般的なYouTube相談や、制作基盤に登録されていない動画には使用しない。
---

# YouTube動画制作

## 目的

複数のYouTubeチャンネルを、Google Driveの作品データ、共通制作パイプライン、Remotion renderer、YouTubeをまたいで再現可能かつ安全に制作する。

このスキルは全チャンネル共通の制作手順だけを扱う。チャンネル名、話者、TTS、字幕、安全域、音声、描画、QAなどの具体値は `youtube-video-pipeline/config/channels/<channel-id>.json`、作品固有値はGoogle Driveの作品データを正本とし、スキルへ複製しない。

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

## 越えてはならない境界

- `paid-api` はユーザーの許可を得るまで実行しない。TTS生成は `--allow-paid-api` なしで呼ばない。
- `human` の承認を推測・代行しない。ユーザーが明示した承認だけを記録する。
- 同じ人物が歩く、走る、引く、振り向くなど複数の連続動作を行う、手と綱・足と地面など複数の接点を拘束する、または縦横・複数作品で同じリグを再利用する場合は、実装前にRiveを第一候補として評価する。採否、編集元、runtime素材、ライセンス、代替方式を `animation-engine-decision.json` へ記録する。
- RiveをRemotionへ組み込む場合は `autoplay` や `requestAnimationFrame` の実時間へ依存させず、Remotionの `frame` と `fps` から一定刻みで状態を進める。Riveを採用しない場合も、関節運動、足の接地、物理接点、状態間補間を同等に検証する。
- 動きを含む映像は、Driveレビューへ入れる前に実尺のmotion clip、8時点以上のcontact sheet、reviewContextを作り、実装者以外の3エージェントで独立レビューする。静止画だけでアニメーション品質を承認しない。
- レビュアーはmotion-physics、art-composition、editing-semanticsを1役ずつ担当し、全員の提出完了まで互いの判定を共有しない。3名全員PASS、blocker/majorゼロ、各項目3.5/5以上、平均4.0/5以上を満たさなければDriveレビューへ進めない。
- 1名でもREWORKなら修正後にmotion clipとcontact sheetを再生成し、前回合格者を含む3名全員で再レビューする。結果は入力ハッシュとともに `animation-quality-review.json` へ保存する。
- MP4描画前に長尺と初期化済み全Shortsの音声・全シーン画像レビューを生成し、人のレビュー承認を得る。
- 台本、音声、素材、映像実装、レビュー成果物が変わった場合は古い承認やQAを再利用しない。
- YouTubeへの変更前に、OAuthで認証された実チャンネルIDとprofileの `youtubeChannelId` が一致することを確認する。不一致時は操作しない。
- YouTubeへのアップロード、metadata更新、サムネイル設定、公開、Studio保存は、対象IDと差分を事前検証し、対応する確認フラグとユーザーの権限範囲を守る。
- 公開状態は依頼なしに変更しない。Studio操作で公開設定へ触れない。
- YouTube Studioの非公開APIを直接呼ばず、表示中の公式UIだけを操作する。
- ユーザーが開いている通常ブラウザを閉じたり、普段使いのプロファイルを直接操作したりしない。
- 秘密鍵、OAuthトークン、Cookie、一時ブラウザプロファイル、`.env.local`、サービスアカウントJSONをGitへ追加しない。

## 制作上の不変条件

- 長尺・Shortsの台本はGoogle Doc `台本` を人間編集用正本とし、`台本.md` は制作パイプライン用の生成ミラーとして扱う。
- ユーザーコメントが付いた台本はコメントを読まずに次工程へ進めず、反映済みコメントだけを解決する。
- 話題固有素材の原本は作品ディレクトリへ置き、`assets register` で出典、権利、用途、ハッシュを登録する。
- 素材scopeは `project`、`channel`、`common` のいずれかにし、重複配置しない。
- `public/input/<channel-id>/<project-id>` と `src/generated/<channel-id>` は同期コピーであり、直接編集しない。
- 素材追加とComposition実装を別工程にする。
- 各発話の映像設計に `semanticBeat`、`visualStrategy`、`assetIds`、`motion`、`sfxCue` を持たせ、台詞のどの意味を何で見せるかを実装前に確定する。
- 多関節キャラクターは単純なSVGグループ移動から始めず、Riveの骨、IK、制約、状態遷移で解けるかを先に判定する。ライブラリを追加するだけで品質向上とみなさず、実際のリグ、キー、接点、遷移をレビュー対象にする。
- 表現の優先順位は、因果・時間変化・物理的な比喩ならアニメーション、人物・場所・商品・出来事など具体物なら権利確認済みの外部写真・動画、抽象概念だけなら動く図解とする。図解を先に選ばない。
- 外部写真・動画はインターネット上の公式素材、パブリックドメイン、利用条件が明確なストック素材を優先する。利用可能な外部素材がない場合を除き、題材固有画像を自作して代替しない。
- 写真を枠内へ静止貼り付けせず、パン、ズーム、クロップ移動、マスク、パララックスのいずれかで映像として動かす。汎用カード、PowerPoint風の囲み、静止テキストだけを主画面にしない。
- 質問、驚き、導入の発話では、その後の答え、分類、結論を先に画面へ出さない。`semanticBeat` の開始より前に将来の情報を表示しない。
- 箇条書き、順序、比較、因果の構造をレイアウトで保持する。縦の列挙を理由なく横並びへ変えず、順序がある項目は順番に出す。
- 動きの意味が切り替わる箇所へ、効果音ラボなど権利確認済みの効果音を必要最小限で同期する。効果音の出典・利用条件を確認し、`sfxCue` に記録する。
- 字幕時刻は `caption-plan.json` のcueを唯一の時刻源とする。
- 発話の `referenceIds` と `video-plan.json` のリファレンス定義を一致させる。
- 意味の異なる発話へ同じ汎用図解を使い回さず、レビュー静止画だけでもvisual IDごとの差が分かるようにする。
- 全シーンレビューでは、台詞との意味一致、質問での答え先出し、素材の有無、動きの設計、箇条書きの構造、効果音キューを確認する。汎用カードの反復、具体物の画像不足、静止画の貼り付け、意味より先の情報表示が1件でもあれば承認可能と扱わない。
- アニメーションレビューでは、背景・線・マーカーだけが動いて動作主体が静止する、物理的に連結した要素の接点がずれる、Sequence境界で姿勢が跳ぶ、入退場が横滑りだけ、通常動作中に見切れる、縦版が単純クロップになる状態を1件でも承認可能と扱わない。
- 作品固有実装は `src/channels/<channel-id>/videos/<project-id>` へ閉じ、形式として再利用する表現だけを `src/formats/<format-id>`、技術だけの共通処理を `src/common` へ置く。

## 変更後の確認

1. データや工程を変更したら `status <project-id> --json` を再実行する。
2. コードを変更したら対象リポジトリの `npm run check` を実行する。
3. 描画物は用途に合う実寸とスマートフォン相当の縮小表示で目視確認する。
4. YouTubeへ変更したらAPI状態だけで完了にせず、再読込後のStudioまたは実際の配信画像・再生画面で反映を確認する。
5. 一時ログ、診断画像、一時ブラウザプロファイルを安全に削除し、秘密情報や生成物がGit差分へ入っていないことを確認する。
