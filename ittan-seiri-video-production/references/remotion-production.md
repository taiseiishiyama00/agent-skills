# Remotion制作

## 責務

制作全体の工程制御とパラメータは `ittan-seiri-video-pipeline` が担う。rendererでは、Remotionの共通オブジェクトと作品固有Compositionだけを管理する。

実装前にrendererの `docs/ARCHITECTURE.md` を全文読み、パイプラインの次の出力を実装契約として使用する。

```sh
npm run pipeline -- remotion task <project-id> --json
```

## 実装手順

1. パイプラインで音声、字幕、映像設計、登録済み素材を同期する。
2. 必要な共通素材を `public/assets` へ追加する。
3. 複数作品で再利用する表現を `src/framework` に実装する。
4. 作品固有の構成と演出を `src/videos/<projectId>` に実装する。
5. Compositionを `src/Root.tsx` へ登録する。
6. 型、Lint、テストを実行する。
7. パイプラインで全シーン静止画を生成し、人のレビュー承認を得る。
8. パイプラインで確認用動画を描画し、人の承認後に全編描画とQAを行う。

## 素材境界

- 作品固有素材の原本はGoogle Driveへ置く。
- `public/input/<projectId>` と `src/generated` はパイプラインが作るGit管理外の同期コピーであり、直接編集しない。
- アバター、BGM、ジングル、効果音など複数作品で使うものだけを `public/assets` へ置く。
- 既存の共通部品を優先し、作品固有の都合で人物・字幕・安全域の共通配置を上書きしない。

## 検証

```sh
npm run check
```

必要に応じてComposition一覧、代表フレーム、全シーン静止画、最終動画を確認する。縦画面は実寸だけでなくYouTube Studio一覧相当の縮小サイズでも、フック、人物、字幕が判別できることを確認する。
