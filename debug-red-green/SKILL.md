---
name: debug-red-green
description: バグ修正、失敗テスト、flaky テスト、回帰、実行時エラー、想定外の挙動、ログベースのデバッグに使用する。Red-Green-Refactor と仮説駆動の手順に従う。純粋な新機能実装には使用しない。
---

# Debug Red-Green

## 目的
バグ修正を「再現 -> Red -> 原因特定 -> 最小修正 -> Green -> 後始末」で進める。
原因が自明で、既存の失敗テストがすでに証明している場合を除き、いきなり production code を編集しない。

## 原則
- ユーザーの変更を上書きしない。
- 1つのバグ、1つの修正、1つの検証経路に絞る。
- 現在の壊れた挙動に合わせるためだけにテストを変更しない。
- テストを通すためにアサーションを弱めない。
- 推測で patch を重ねない。失敗したら仮説へ戻る。
- 無関係なリファクタリング、整形、依存更新を混ぜない。
- 修正方針が複数あり得る場合は、候補・根拠・トレードオフを出してユーザーと決める。
- テストまたは再現コマンドの証拠なしに「直った」と主張しない。

## 事前確認
コード変更前に、可能な範囲で次を特定する。不足分はリポジトリから推論し、進行を止める情報だけユーザーへ確認する。

- バグの説明
- 期待される挙動
- 実際の挙動
- 再現コマンドまたは再現手順
- 影響範囲
- 関連ログ、スタックトレース、スクリーンショット、失敗テスト
- 直近変更、設定変更、依存更新、環境差分

最初に git 状態を見て、ユーザーの未コミット変更を把握する。

## 1. 再現
失敗を再現する最小コマンドを実行する。

- 対象は unit / integration / UI test、CLI、API、最小ローカルシナリオのいずれか。
- コマンド、終了コード、主要な失敗出力、決定的かどうかを記録する。

再現できない場合は、ログ・既存テスト・最小再現を探す。まだ再現できていない状態で根本原因を断定しない。

## 2. Red
バグを捕まえる失敗テストを作成または選択する。

- 現在のコードで失敗すること。
- 狙った理由で失敗すること。
- できるだけ public behavior を見ること。
- 範囲は狭くすること。
- flaky の場合は複数回実行し、機能バグとテスト不安定性を分けること。

記録:

```text
Red:
- test:
- command:
- failure:
- why:
```

## 3. 仮説
production code を触る前に、反証可能な仮説を2-4個置く。

```text
Hypothesis:
- claim:
- evidence:
- experiment:
- expected if true:
- expected if false:
```

直近コミット、設定、依存、DB schema、cache、env、timezone、async race、外部サービスも必要に応じて候補に入れる。

## 4. 観測
仮説を切り分ける最小限の観測だけ追加する。

- 一時ログ、対象を絞った assertion、trace id、テスト専用診断、debugger、狭い dump は可。
- business behavior を変える観測、広範囲ログ、一時ログの放置は禁止。
production observability として残す場合は、既存 logger 規約と log level に合わせる。

## 5. 根本原因
実験結果から、根本原因を証拠付きで明示する。

```text
Root cause:
- defect:
- location:
- trigger:
- why tests missed it:
- evidence:
```

根本原因が証拠で裏付けられるまで最小修正へ進まない。

## 6. 最小修正
根本原因だけを直す。

- Red テストが証明していない既存挙動は維持する。
- public API、設定、schema、wire contract に触れる場合は明示する。
- バグ修正と cleanup を混ぜない。
- 方針が一意でない場合は実装前に止める。

## 7. Green
狭い範囲から広い範囲へ検証する。

1. Red テスト
2. 近傍テスト
3. 関連する integration / UI test
4. 必要に応じて lint、build、typecheck

失敗したら修正を積み増す前に仮説へ戻る。

## 8. 後始末
Green 後にだけ行う。

- 一時ログ、debug assertion、作業用 dump を削除する。
- 正当化できる production observability だけ残す。
- 直接関係する場合だけ簡潔化する。
- 後始末後に Red テストを再実行する。

## 9. 回帰確認
根本原因に直接関係する edge case だけ追加で見る。

- null / empty / boundary
- timezone / ordering
- async race
- cache invalidation
- retry / idempotency
- serialization
- auth / permission
- feature flag / env
- dependency / external service

## サブエージェント
使う場合は read-heavy な独立調査に限る。

- ログ解析、stack trace 調査、関連コード探索、既存テスト調査、flaky 候補、直近 diff 調査。
- バグ定義、Red 採用、根本原因、production 修正、最終検証は親エージェントが責任を持つ。
同じバグで複数サブエージェントに production code を同時編集させない。

## リソース
- 長い調査では `references/debug-note-template.md` を使う。
- 実装前と最終報告前に `references/bugfix-checklist.md` を使う。
- コンパクトな状態把握には `scripts/collect_context.sh` を使う。
- 永続メモは、ユーザーが求めた場合か、文脈喪失リスクが高い複雑なバグの場合だけ残す。

## 最終報告
```text
Summary:
- bug:
- root cause:
- fix:
- tests changed:
- validation:
- temporary debug removed:
- residual risk:
```
