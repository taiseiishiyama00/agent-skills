---
name: csharp-coding-rules
description: C#、ASP.NET Core、.NET Core、.NET の実装・修正・レビューで使用する。DI、static class、ファイル分割、XML comment、コメント、可読性、固定手順のコードクリーンアップ、文字コードに関するコーディングルール。
---

# C# Coding Rules

## 設計 / 可読性

- 業務ロジックと外部依存は static class に置かず、interface を constructor injection する。DI の命名と lifetime は既存規約に合わせる。
- static class は、拡張メソッド、定数、entry point、小さな純粋関数に限る。
- 1ファイル1型とし、型名とファイル名を一致させる。interface と実装も分ける。既存の複数型は今回触る範囲で分割する。
- 意図は命名と責務分割で表す。コメントはコードから読めない「なぜ」だけを書き、処理をなぞるコメントは削除する。
- 外部から参照される public method には、目的、引数、戻り値、例外条件の XML comment を書く。

## 完了時コードクリーンアップ

C# を変更したら、今回触った `.cs` だけを対象に次を必ず実行する。既存差分、生成コード、外部由来コードは含めない。コードを変更しないレビューでは実行しない。

各 `.cs` から最も近い単一の `*.csproj` を workspace とする。見つからない、または複数ある場合は推測せず完了報告を止める。

```powershell
pwsh -NoProfile -File <skill-directory>/scripts/cleanup-csharp.ps1 `
  -Workspace <project.csproj> `
  -Include <changed-file-1.cs>, <changed-file-2.cs>
```

スクリプトは `.editorconfig` に従って、Visual Studio の「Format Document」（文字コード・改行を含む）と「Remove and Sort Usings」を実行し、`--verify-no-changes` で再実行時に差分が出ないことまで確認する。GUI、手作業、別の formatter で代替しない。終了コードが0でなければ原因を直して再実行する。成功後は対象外の差分や挙動変更がないことを確認する。

## 完了前チェック

- 変更範囲の `dotnet build`、近傍テスト、既定の lint / analyzer を実行する。
- 今回の変更による warning と EditorConfig エラーを残さない。既存分は増えていないことを確認し、件数と理由を報告する。
- 実行できない検証は、理由と残リスクを報告する。
