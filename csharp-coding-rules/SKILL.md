---
name: csharp-coding-rules
description: C#、ASP.NET Core、.NET Core、.NET の実装・修正・レビューで使用する。DI、static class、ファイル分割、コメント、可読性に関するコーディングルール。
---

# C# Coding Rules

## 適用方針

C# / .NET の実装では、テストしやすく、差し替えやすく、読みやすいコードを優先する。

## DI / static class

- DI が使える環境では、業務ロジックや外部依存を static class に置かず、interface と DI で注入する。
- static class は、拡張メソッド、定数、framework entry point、小さな純粋関数など差し替え不要な用途に限る。
- 呼び出し側は具象 class を直接 new せず、constructor injection で interface を受け取る。
- DI 登録場所、service 命名、lifetime は既存プロジェクトの規約に合わせる。

## ファイル分割

- 1 ファイルに複数の class、interface、record、struct、enum、delegate、DTO などを定義しない。
- 型名とファイル名を一致させる。
- interface と実装 class は別ファイルに分ける。
- 既存ファイルに複数型がある場合は、今回触る型を中心に安全な範囲で分割する。

## コメント / 可読性

- コメントで説明しないと読めないコードにせず、命名、型、メソッド分割、責務分割で意図を表す。
- コメントは、コードから読み取れない制約、仕様理由、外部システム都合など「なぜ」に絞る。
- 処理内容をなぞるだけのコメントは削除する。
- public API の XML comment は、プロジェクト規約や公開 API として必要な場合だけ書く。

## 完了前チェック

- 作業完了前に、変更範囲に対して `dotnet build`、近傍テスト、またはリポジトリで定義された lint / format / analyzer コマンドを実行し、warning、analyzer 診断、EditorConfig 由来のエラーを確認する。
- 新規または変更したコードに起因する warning / EditorConfig エラーは、できるだけ減らしてから完了報告する。
- 既存由来の warning が残る場合は、今回の変更で増やしていないことを確認し、残した理由や未解消の件数を最終報告に含める。
- 検証コマンドを実行できない場合は、実行できなかった理由と残リスクを明記する。
