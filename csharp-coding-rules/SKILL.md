---
name: csharp-coding-rules
description: C#、ASP.NET Core、.NET Core、.NET の実装・修正・レビューで使用する。DI、static class、ファイル分割、XML comment、コメント、可読性、引数の null check、テスト構成、NSubstitute、固定手順のコードクリーンアップに関するコーディングルール。
---

# C# Coding Rules

## 設計 / 可読性

- 業務ロジックと外部依存は static class に置かず、interface を constructor injection する。DI の命名と lifetime は既存規約に合わせる。
- static class は、拡張メソッド、定数、entry point、小さな純粋関数に限る。
- 1ファイル1型とし、型名とファイル名を一致させる。interface と実装も分ける。既存の複数型は今回触る範囲で分割する。
- 意図は命名と責務分割で表す。コメントはコードから読めない「なぜ」だけを書き、処理をなぞるコメントは削除する。

## テスト / テスト構成

- 自動テストで依存関係をモックする場合は、NSubstitute を基本のモックライブラリとして使用する。モックが不要な対象を無理に置き換えず、実オブジェクトで検証できる場合は実オブジェクトを使用する。
- 1つの対象 C# プロジェクトに対して、対応するテストプロジェクトを1つ作る。複数の対象プロジェクトを1つのテストプロジェクトへ混在させない。
- 1つの対象クラスに対して、対応するテストクラスを1つ作る。複数の対象クラスのテストを1つのテストクラスへ混在させない。テストケースが複数ある場合も対象クラス単位で同じテストクラスにまとめる。

## 公開境界

次のいずれかに該当する method だけを公開境界とする。

- HTTP API の入口となる Controller action または Minimal API handler。
- プロジェクト直下に `PublicAPI.Shipped.txt` または `PublicAPI.Unshipped.txt` があるライブラリの public method。

公開境界では次を行う。

- 公開契約側の宣言に、目的、引数、戻り値、例外条件の XML comment を書く。interface がある場合は interface 側だけに書く。
- 実装の先頭で、null を許容しない参照型引数を宣言順に `ArgumentNullException.ThrowIfNull` で検証する。

公開境界以外の method には、規約を理由に XML comment または null check を追加しない。nullable (`T?`) 引数、値型、同じ引数を既に null 検証している場合も null check を追加しない。

## 完了時コードクリーンアップ

C# を変更したら、今回触った `.cs` だけを対象に次を必ず実行する。既存差分、生成コード、外部由来コードは含めない。コードを変更しないレビューでは実行しない。

各 `.cs` から最も近い単一の `*.csproj` を workspace とする。見つからない、または複数ある場合は推測せず完了報告を止める。

```powershell
pwsh -NoProfile -File <skill-directory>/scripts/cleanup-csharp.ps1 `
  -Workspace <project.csproj> `
  -Include <changed-file-1.cs>, <changed-file-2.cs>
```

スクリプトは `.editorconfig` に従うコードクリーンアップを実行し、同じ対象への `--verify-no-changes` で再実行時に差分が出ないことまで確認する。GUI、手作業、別の formatter で代替しない。終了コードが0でなければ原因を直して再実行する。成功後は対象外の差分や挙動変更がないことを確認する。

## 完了前チェック

- 変更範囲の `dotnet build`、近傍テスト、既定の lint / analyzer を実行する。
- 今回の変更による warning と EditorConfig エラーを残さない。既存分は増えていないことを確認し、件数と理由を報告する。
- 実行できない検証は、理由と残リスクを報告する。
