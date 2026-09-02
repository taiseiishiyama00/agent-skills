---
name: youtube-video-production
description: 設定済みYouTubeチャンネルの横動画・Shortsについて、企画、台本、TTS、字幕、素材、Remotion、レビュー、サムネイル、投稿、終了画面、関連動画を新規作成・修正・検証するときに使用する。一般的なYouTube相談や、制作基盤に登録されていない動画には使用しない。
---

# YouTube動画制作

## 目的

複数のYouTubeチャンネルを、Google Driveの作品データ、共通制作パイプライン、Remotion renderer、YouTubeをまたいで再現可能かつ安全に制作する。

## チャンネルごとの単一正本

動画制作・品質・出力要求は、チャンネルごとに次の1ファイルだけを正本とする。

```text
references/channels/<channel-id>/video-standard.md
```

動画制作または制作基盤の変更を始める前に、対象チャンネルの正本を必ず全文読む。対象チャンネルの正本が存在しない場合は制作を開始せず、ユーザーと要求を確認して正本を作成する。

- ユーザーは対象チャンネルの `video-standard.md` だけを確認すればよい状態を保つ。
- AIは正本を解釈し、作品データ、チャンネル設定、CLI、renderer、テストへ具体化する。
- `SKILL.md` はAIの実行規約、その他の `references/` は正本から詳細化した手順書、設定・コード・テストは機械実装であり、別の正本にしない。
- 手順書は正本の要求IDを参照し、正本にない必須条件、品質ゴール、例外を追加しない。矛盾時は正本を優先し、手順書と実装を修正する。
- 設定・コード・テストへ要求を実装するときは、対応する正本の要求IDと版を追跡できるようにする。
- 暗黙の必須条件や品質ゴールを発見した場合、作品固有コードだけで対処せず、先に正本へ要求ID付きで追加する。

## 正本を変更するとき

動画ルールの追加・変更・削除は次の順序で行う。

1. 対象チャンネルの `video-standard.md` を先に変更し、要求ID、適用対象、合格条件、例外条件を明確にする。
2. 要求を `自動検証`、`自動生成`、`人またはAIの判断を含む検査` に分類する。
3. 決定的に判定できるものは、可能な限りpipeline、renderer、設定schema、テストへ実装する。
4. 意味、見た目、権利、最新の外部仕様など機械判定だけでは不十分なものは、正本の要求IDから詳細化した手順書とチェック結果で再現可能にする。
5. 正本、実装、テスト、手順書の対応を確認し、未実装要求を理由なく残さない。直ちに自動化できない場合は、正本の実装状況へ理由と代替検査を記録する。

数値や文言を変更するときも設定だけを先に変更せず、正本を更新したうえで対応する設定・実装・テストを同じ作業で更新する。

## 対象ワークスペース

- `youtube-video-pipeline`: 工程制御、検証、TTS、字幕、素材台帳、承認、QA、YouTube操作
- `youtube-remotion-renderer`: 技術共通、動画形式、チャンネル、作品ごとのRemotion実装
- `youtube-production/common`: 複数チャンネルが同一条件で使う制作資産
- `youtube-production/channels/<channel-id>/assets`: チャンネル固有のブランド資産
- `youtube-production/channels/<channel-id>/projects`: 作品固有の台本、音声、素材、動画、投稿情報

配置は推測で固定せず、pipelineの検出結果と環境変数を優先する。見つからなければ `doctor --json` のエラーを根拠に停止する。

## 作業開始

1. 依頼または作品情報から `<channel-id>` と `<project-id>` を確定する。
2. `references/channels/<channel-id>/video-standard.md` を全文読み、適用される要求IDを特定する。
3. 対象リポジトリの `git status --short` を確認し、既存の未コミット変更を保護する。
4. pipelineで次を実行する。

```sh
npm run pipeline -- --channel <channel-id> doctor --json
npm run pipeline -- --channel <channel-id> status <project-id> --json
npm run pipeline -- --channel <channel-id> next <project-id> --json
```

5. 作品の `channelId` とprofileが一致することを確認する。
6. `next` が返す未完了工程から進め、正常な成果物を理由なく再生成しない。
7. 対象工程の派生手順書を全文読む。

## 派生手順書

手順書は正本の要求をどう満たすかだけを具体化する。要求の有無、優先順位、合格条件は対象チャンネルの `video-standard.md` で判断する。

- 新規登録、TTS、字幕、素材、同期、レビュー、QA、YouTube Data API操作: [references/pipeline-cli.md](references/pipeline-cli.md)
- 横動画またはShortsの工程全体、次工程の判断: [references/workflow.md](references/workflow.md)
- 横動画・Short台本のGoogle Docs共同編集、コメント反映、同期: [references/script-collaboration.md](references/script-collaboration.md)
- ニュース解説台本の調査、構成、生活への接続: [references/news-explainer-script.md](references/news-explainer-script.md)
- Shortの台本、縦画面、サムネイル、公開前後の確認: [references/shorts-production.md](references/shorts-production.md)
- 終了画面、チャンネル登録、Shortの関連動画、専用Edge操作: [references/youtube-studio.md](references/youtube-studio.md)
- Remotionの所有境界、Composition実装、テスト: [references/remotion-production.md](references/remotion-production.md)
- 機械判定できない映像・音声・字幕・権利・公開結果の検査: [references/quality-review-runbook.md](references/quality-review-runbook.md)

複数領域にまたがる依頼では該当する手順書をすべて読み、関係のない手順書は読み込まない。

## 実装方針

- 配置は正本の所有境界に従い、最も狭い所有者へ置く。
- 将来使えそうという理由だけで共通化せず、2つ目の利用先と同一契約が確認できてから上位へ移す。
- 下位層から上位層への依存だけを許可し、共通層から特定チャンネル・作品へ依存させない。
- pipelineが生成する実装契約には、適用する正本の版と要求IDを含める。
- 自動検証で不合格にできる要求を、AIへの自然言語指示だけで済ませない。
- 正本の要求は、再現性と冪等性のある手段で実現する。同じ入力と版で再実行した場合は同じ成果物・判定になるか、既に満たしていれば安全なno-opになるようにする。
- 手作業の記憶、担当者だけが知る操作、未記録のGUI状態など、再実行できない隠れた状態へ依存しない。
- 可能な限りツール化し、入力検証、dry-runまたは差分表示、実行、事後条件の検証、構造化された結果を一連の処理にする。
- 完全自動化できない検査も、要求ID、入力、観点、合否、証拠を固定した手順書またはチェックツールで半機械化する。
- 作品固有の例外はユーザーの明示承認と理由を作品データへ記録し、共通ルールを書き換えたことにしない。

## 越えてはならない境界

- 有料API、human承認、YouTube変更、秘密情報、公開状態に関する正本の安全要求とpipelineの確認フラグを守る。
- `human` の承認を推測・代行しない。
- ユーザーの依頼なしに公開状態を変更しない。
- YouTube Studioの非公開APIを直接呼ばない。
- ユーザーが開いている通常ブラウザを閉じたり、普段使いのプロファイルを直接操作したりしない。
- 秘密鍵、OAuthトークン、Cookie、一時ブラウザプロファイル、`.env.local`、サービスアカウントJSONをGitへ追加しない。

## 完了条件

1. 適用対象の要求IDごとに、自動検証結果または派生手順書による検査結果がある。
2. データや工程を変更したら `status <project-id> --json` を再実行する。
3. コードを変更したら対象リポジトリの `npm run check` を実行する。
4. 描画物は正本が要求する実寸・縮小表示・再生条件で確認する。
5. YouTubeへ変更したら、再読込後のStudioまたは実際の配信画像・再生画面で反映を確認する。
6. 一時ログ、診断画像、一時ブラウザプロファイルを安全に削除し、秘密情報や生成物がGit差分へ入っていないことを確認する。
7. 正本と実装の対応表に未説明の欠落がないことを確認する。
