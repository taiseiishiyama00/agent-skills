# YouTube Studio限定設定

> この文書は派生手順書であり、終了画面・関連動画の正本ではない。対象チャンネルの `channels/<channel-id>/video-standard.md` が定める公開後の状態を、公式UIで再現・検証する方法だけを定める。

終了画面とShortの関連動画は、YouTube Data APIやStudioの非公開APIではなく、YouTube Studioの表示中の公式UIで設定する。

公式確認先:

- https://support.google.com/youtube/answer/6388789?hl=ja
- https://support.google.com/youtube/answer/14075157?hl=ja

## 事前検証

1. `<channel-id>` のprofileにある `youtubeChannelId` とOAuthで認証された実チャンネルIDを照合する。
2. 対象横動画ID、Short ID、終了画面で指定する動画IDを、パイプラインの投稿情報とYouTube Data APIの結果で照合する。
3. 関連動画または終了画面に選べる公開状態か確認する。
4. 公開状態、子ども向け設定、対象IDのいずれかが条件を満たさない場合は保存操作を止める。
5. 横動画終了画面の表示時間はStudioの既定値ではなく、`video-plan.json` の `timing.endingFrames` を `config/channels/<channel-id>.json` の横動画のFPSで割って算出する。
6. preflight結果の対象ID、`durationSeconds`、`positionPreset` を確認する。

```powershell
$env:YOUTUBE_CHANNEL = "<channel-id>"
node scripts/youtube-studio-preflight.mjs `
  --project <project-id> `
  --long-id <long-video-id> `
  --short-id <short-video-id> `
  --previous-video-id <end-screen-video-id>
```

## ログイン状態の診断

普段使いのブラウザプロファイルを直接操作しない。診断は読み取りコピーした一時プロファイルで行い、ユーザーが開いているブラウザを閉じない。

```powershell
node scripts/youtube-studio-diagnose.mjs --browser chrome
node scripts/youtube-studio-diagnose.mjs --browser edge
node scripts/youtube-studio-diagnose.mjs --browser edge --video-id <video-id> --page editor
```

- Cookie DBが使用中で安全なコピーを作れない場合は、ブラウザを強制終了せず停止する。
- 診断用ブラウザと一時コピーは終了時に削除する。
- 診断画像にはアカウント情報が写る可能性があるため、外部共有やGit追加をしない。
- `clonedProfileRemoved: true` を確認する。異常終了時は一時プロファイルの残存を確認する。

## 操作用Edge

ユーザーがログインする専用Edgeを、`127.0.0.1` だけで待ち受けるローカルCDPとして起動する。専用プロファイルを保持すれば、Google側でセッションが切れるまでログイン状態を再利用できる。

```powershell
& "$env:ProgramFiles(x86)\Microsoft\Edge\Application\msedge.exe" `
  --user-data-dir="$env:LOCALAPPDATA\Codex\YouTubeStudioProfile" `
  --remote-debugging-port=9224 `
  --remote-debugging-address=127.0.0.1 `
  --disable-sync `
  --disable-extensions
```

設定ツールは `--confirm-save` がない限り保存しない。要素不足、動画ID違い、固定動画でない状態、要素サイズ違いでは停止し、公開設定を操作しない。

## 横動画の終了画面

1. `https://studio.youtube.com/video/<long-video-id>/editor` を開き、終了画面を表示する。
2. 「特定の動画」1件へ事前確認した動画IDを設定する。
3. 「チャンネル登録」1件を追加する。
4. 読み取りモードで現在値と期待値の差分を確認する。

```powershell
npm run studio:end-screen -- `
  --project <project-id> `
  --video-id <long-video-id> `
  --port 9224
```

5. 差分が対象動画、2要素の配置、映像設計から算出した表示時間だけであることを確認する。
6. ユーザーの保存許可範囲を確認し、適用と保存を明示する。

```powershell
npm run studio:end-screen -- `
  --project <project-id> `
  --video-id <long-video-id> `
  --port 9224 `
  --apply `
  --confirm-save
```

7. 次を検証する。

   - 動画要素が固定動画で、指定IDと一致する。
   - 動画要素は左下、チャンネル登録要素は右下の共通実寸プリセットと一致する。
   - 2要素の表示時間が映像設計のエンディング尺と一致する。
   - 2要素の開始オフセットが一致する。
   - `privacySettingsTouched` が `false` である。

8. エディタが `0:00:00` や初期状態のまま止まった場合は保存を連打しない。同じ専用Edge内の新しいエディタタブで読み取りを再試行する。

Remotionの案内枠は、Studioで保存された実要素の外側へ均等に描く。目視だけで枠を広げたり、Studio要素を枠へ合わせて都度ずらしたりしない。

## Shortの関連動画

1. `https://studio.youtube.com/video/<short-video-id>/edit` を開く。
2. 「関連動画」で事前確認した自チャンネルの横動画を選択する。
3. 選択されたタイトルと動画IDを確認する。
4. 公開設定など他の差分がないことを確認して保存する。

関連動画として選べる条件と高度な機能へのアクセス要件は、作業時のYouTube公式仕様で確認する。

## 事後検証

1. preflightとYouTube状態取得を再実行し、対象IDと公開状態が変わっていないことを確認する。
2. 横動画エディタを再読込し、固定動画、チャンネル登録、表示時間、実寸配置が残っていることを読み取りモードで確認する。
3. Short詳細画面を再読込し、関連動画が指定した横動画になっていることを確認する。
4. 実際の再生画面で、エンディング開始前には要素が出ず、開始後に動画とチャンネル登録が案内枠へ収まることをスマートフォンで確認する。
5. Shortの再生画面で関連動画のタイトルと遷移先を確認する。
6. 公開設定のUIや `publish` コマンドへ依頼なしに触れない。
