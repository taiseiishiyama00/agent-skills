# 「いったん整理。」台本テンプレート

台本は人間主体で作成する。横動画用とShort用にGoogle Docsを1つずつ作り、次のテンプレートに従う。

## 横動画

```text
[見出し1] <動画タイトル>

[見出し2] chapter: skit | 冒頭コント
[標準テキスト] <speaker-id>: <発話本文>
[標準テキスト] <speaker-id>: <発話本文>

[見出し2] chapter: opening | オープニング
[標準テキスト] <speaker-id>: <発話本文>

[見出し2] chapter: chapter-01 | <章の表示名>
[標準テキスト] explainer: <1つ目の回答>
[標準テキスト] explainer: <2つ目の回答>

[見出し2] chapter: chapter-02 | <章の表示名>
[標準テキスト] explainer: <1つ目の回答>

（必要な章数だけ chapter-03 以降を連番で追加する）

[見出し2] chapter: summary | まとめ
[標準テキスト] host: <1つ目の要点>
[標準テキスト] host: <2つ目の要点>
```

通常章では `explainer:` の標準テキスト段落1つを1回答、`summary` では `host:` の標準テキスト段落1つを1要点として扱う。シーン設計では、各対象段落に対応する内容ビジュアルを用意する。

## Short

```text
[見出し1] <動画タイトル>

[見出し2] segment: skit | 冒頭コント
[標準テキスト] <speaker-id>: <発話本文>
[標準テキスト] <speaker-id>: <発話本文>

[見出し2] segment: summary | 解説サマリ
[標準テキスト] explainer: <1つ目の回答>
[標準テキスト] explainer: <2つ目の回答>
```

見出し2は区間判定だけに使い、映像のインサートにはしない。`summary` では `explainer:` の標準テキスト段落1つを1回答として扱い、解説サマリの先頭と各対象段落に対応する内容ビジュアルを用意する。末尾の固定CTAはGoogle Docsへ書かず、チャンネル設定から音声生成時に自動追加する。

## 共通ルール

発話は標準テキストの段落ごとに `<speaker-id>: <発話本文>` と書く。`speaker-id` はチャンネル設定の `host` または `explainer` を使う。
