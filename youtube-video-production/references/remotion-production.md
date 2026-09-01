# Remotion制作

## 責務

制作全体の工程制御とパラメータは `youtube-video-pipeline` が担う。rendererでは技術共通、形式共通、チャンネル固有、作品固有を混ぜずに管理する。

実装前にrendererの `docs/ARCHITECTURE.md` を全文読み、パイプラインの次の出力を実装契約として使用する。

```sh
npm run pipeline -- --channel <channel-id> remotion task <project-id> --json
```

## 実装手順

1. パイプラインで音声、字幕、映像設計、登録済み素材を同期する。
2. チャンネル固有素材を `public/assets/channels/<channel-id>`、全チャンネル共通素材を `public/assets/common` へ追加する。
3. Remotionやフォントなど技術だけの共通処理を `src/common` に実装する。
4. 複数チャンネルで再利用する形式の契約と表現を `src/formats/<format-id>` に実装する。
5. 多関節人物、接点拘束、再利用キャラはRiveを第一候補として評価し、採否と代替リグを `animation-engine-decision.json` に記録する。
6. ブランドとComposition登録を `src/channels/<channel-id>`、作品固有の構成と演出をその `videos/<project-id>` に実装する。
7. ルートはチャンネルComposition集合だけを読み込み、作品を直接列挙しない。
8. 型、Lint、テストを実行する。
9. パイプラインで長尺を章境界ベースの最大6segment、Shortsを1本ずつのMP4として生成し、segmentごとのreviewContextを用意する。
10. 各MP4を実時間で検査し、人のsegment別承認を得る。局所修正は該当segmentだけ、横断修正は全segmentを再描画する。
11. 全segment承認後に全編描画とQAを行う。音声単体、全シーン静止画、contact sheet、motion clip、旧preview動画はレビュー承認工程に含めない。

## 素材境界

- 作品固有素材の原本はGoogle Driveへ置く。
- `public/input/<channel-id>/<projectId>` と `src/generated/<channel-id>` はパイプラインが作るGit管理外の同期コピーであり、直接編集しない。
- アバター、ロゴなど1チャンネルのものは `public/assets/channels/<channel-id>`、BGMや効果音など複数チャンネルが同一条件で使うものは `public/assets/common` へ置く。
- 既存の共通部品を優先し、作品固有の都合で人物・字幕・安全域の共通配置を上書きしない。
- 上位層から特定チャンネルや作品へ依存させない。2つ目の利用先が確定するまで、推測で共通化しない。

## 画面設計のガードレール

- 発話ごとに `semanticBeat`、`visualStrategy`、`assetIds`、`motion`、`sfxCue` を定義し、レビューmanifestへ残す。
- 因果、時間変化、物理的な比喩は、静止説明ではなくアニメーションで表現する。
- 人物、場所、商品、ニュース、施設、買い物など具体物は、登録済みの外部写真・動画を必ず使う。利用可能な外部素材がない場合を除き、題材固有画像を自作しない。
- 外部画像はパン、ズーム、クロップ移動、マスク、パララックスのいずれかを付け、枠内へ静止貼り付けしない。
- 抽象概念だけを図解にし、汎用カード、PowerPoint風の囲み、静止テキストだけの画面を作らない。図解も全画面の移動・描画・ワイプで見せる。
- 質問や導入では、その後の答え、分類、結論を表示しない。表示開始を台詞の意味境界より前へ置かない。
- 箇条書きは列挙構造を保持し、順番に表示する。理由なく横並びに圧縮しない。
- 動きの開始、停止、衝突、切替へ権利確認済みの効果音を同期し、出典とキューを記録する。
- 分割MP4レビューで、汎用レイアウトの反復、具体物の画像不足、質問での答え先出し、意味順の逆転、静止画貼り付けが見つかった場合は該当segmentの実装をやり直す。

## アニメーション品質の確認項目

- 同じ人物が複数の連続動作を行う、手足など複数関節の接点を固定する、または縦横・複数作品でリグを再利用する場合はRiveの骨、IK、制約、State Machineを第一候補にする。採否、編集元、runtime用 `.riv`、素材ライセンス、非採用時の代替方式を `animation-engine-decision.json` に残す。
- RemotionからRiveを使う場合は `autoplay` や `requestAnimationFrame` に任せず、`useCurrentFrame()` とfpsに基づいて低レベルruntimeを一定刻みで進める。同じframeを再描画して同じ絵になることを代表フレームのハッシュで確認する。
- Rive非採用は免除ではない。代替リグでも関節運動、足の接地、手と綱などの物理接点、状態間の予備動作と補間を満たす。
- segment MP4は実際の尺・fps・縦横構図で、動作の開始、接触、主動作、離脱、終了を含める。reviewContextは確認対象を動画内時刻で指定する。
- 確認観点は、motion-physicsでは接点、重心、足運び、連動、境界ジャンプ、art-compositionでは造形、奥行き、余白、見切れ、重なり、editing-semanticsでは意味順、ビート、主体動作、長尺・縦尺の同等性とする。
- 背景・中央線・マーカーだけが動く、綱と手など接点がずれる、状態境界で姿勢が跳ぶ、入退場が横滑りだけ、通常時に人物が切れる、縦版が横版の単純クロップになる場合は不合格とする。
- 確認結果、segment MP4、reviewContext、入力のハッシュを `animation-quality-review.json` へ保存する。部分再生成では変更segmentだけを失効させ、横断変更では全segmentを失効させる。

## 検証

```sh
npm run check
```

必要に応じてComposition一覧、分割レビューMP4、最終動画を確認する。縦画面はMP4を実寸だけでなくYouTube Studio一覧相当の縮小サイズでも再生し、フック、人物、字幕が判別できることを確認する。
