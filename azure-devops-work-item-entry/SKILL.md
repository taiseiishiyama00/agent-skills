---
name: azure-devops-work-item-entry
description: Azure DevOpsのWeb画面でWork Itemの表示項目を確認し、プロジェクトのプロセスに合わせてBugまたはProduct Backlog Itemを作成・更新するときに使用する。本文だけでなくRepro Steps、System Info、Acceptance Criteria、親子リンクなどの表示項目を適切に入力し、保存後に画面で検証する。
---

# Azure DevOps Work Item登録

## 目的

Azure DevOpsのWork Itemを、対象プロジェクトのWeb画面に表示されるフィールドとプロセスに合わせて登録する。APIの既定フィールドだけを埋めて、Web画面の確認欄が空になる状態を防ぐ。

## 発火例

- 「Azure DevOpsにバグを追加して」
- 「このFeatureの子にBugを作成して」
- 「バックログアイテムを登録して」
- 「既存のWork Itemの内容を画面に表示される欄へ移して」

## 基本ルール

1. 作成前に、認証済みのAzure DevOps Web画面で対象プロジェクト、親Work Item、作成対象のWork Item種別を開く。
2. 作成対象の種別ごとに、実際に画面に表示されるフィールド名、必須入力、初期値、セクションを確認する。BugとProduct Backlog Itemで同じフィールドが表示されるとは限らない。
3. Web画面を確認できない状態で、プロジェクト固有のフィールドや必須値を推測して作成しない。サインインが必要な場合は認証を依頼する。APIを併用する場合も、実際の画面でフィールドへの反映を確認する。
4. 依頼文の情報を、1つのDescriptionへまとめず、画面上の責務に対応する欄へ分けて入力する。
5. 親子関係はタイトルや本文に親IDを書くのではなく、Azure DevOpsのParentリンクとして設定する。
6. 依頼文にないPriority、Severity、Effort、Iterationなどは勝手に決めない。親やチームの既定値を使う場合は、その値を画面で確認し、報告する。
7. 保存後にWork Itemを再表示し、入力欄、種別、タイトル、親子リンク、Area、Iteration、Stateを検証する。保存できなかった項目を成功扱いにしない。

## 作成前のWeb画面確認

次の順で確認する。

1. 親Featureまたは親Work Itemを開き、プロジェクト名、Team、Area、Iteration、既存の子Work Itemを確認する。
2. `New Work Item`から作成対象の種別を選び、入力フォームを表示する。
3. 画面に表示されたフィールドを次の表へ記録する。表の項目は固定値ではなく、画面に存在する場合だけ使う。

| 分類 | 確認する項目 |
| --- | --- |
| 共通 | Title、State、Reason、Area、Iteration、Parent、Discussion、Tags |
| Bug | Repro Steps、System Info、Acceptance Criteria、Priority、Severity、Reported By |
| Product Backlog Item | Description、Acceptance Criteria、Priority、Effort、Value Area、Business Value |
| 関連情報 | Development、Build、Related Work、Attachments |

4. 項目が画面に表示されない場合は、そのフィールドを別の欄へ無理に詰め込まない。プロジェクトのプロセスで利用できる欄を確認し、未入力理由を記録する。
5. 親のArea、Iteration、Priorityなどを引き継ぐ場合は、親または同じ一覧の既存項目で実際の値を確認する。

## 入力内容の分割

### Bug

- **Title**: 再現可能な不具合を短く表す。症状だけでなく、対象機能が分かる名前にする。
- **Repro Steps**: 前提条件、操作手順、期待結果、実際の結果、エラーメッセージを順番に書く。レビューで再現できない場合は、判明している手順と不足情報を分ける。
- **System Info**: アプリケーション、バージョン、環境、Agent/Projectなどの再現に必要な情報を書く。秘密情報やトークンは書かない。
- **Acceptance Criteria**: 修正後に確認できる条件を書く。再現しないこと、状態が残らないこと、UIが継続することなど、観測可能な文にする。
- **DescriptionまたはDiscussion**: 背景、原因の仮説、影響範囲、対応方針を書く。画面にDescriptionがない場合は、Repro StepsやAcceptance Criteriaへ背景を重複させず、表示される適切な欄に分割する。

### Product Backlog Item

- **Title**: 利用者またはプロダクトの価値が分かる形で書く。
- **Description**: 背景、現状、目的、対象範囲、対応方針を書く。
- **Acceptance Criteria**: 完了を判定できる成果物、対象、失敗時の扱い、検証方法を書く。
- **Priority、Effort、Value Area、Iteration**: 依頼または親・チームの既定値を画面で確認した場合だけ設定する。

### 依頼文の整理

長い依頼文は、次の順に整理してから入力する。

1. **現象 / 現状**: 何が起きているか。
2. **目的 / TOBE**: 完了後にどうなるべきか。
3. **原因 / GAP**: 分かっている原因と未確認事項を分ける。
4. **対応内容**: 実装・調査・検証の範囲。
5. **受入条件**: 画面やテストで確認できる条件。
6. **再現情報**: Bugの場合だけ、再現手順と環境を分離する。

## 保存後の検証

保存後、同じWeb画面を再読み込みして、次を1つずつ確認する。

- Work Item ID、種別、Titleが依頼どおりである。
- BugならRepro Steps、System Info、Acceptance Criteriaが表示される。
- Product Backlog ItemならDescription、Acceptance Criteriaなど、作成前に確認した欄が表示される。
- State、Reason、Area、Iteration、Priority、Severity、Effortが意図した値である。
- Related WorkにParentが表示され、親IDが正しい。
- 保存時のエラーや未入力欄が残っていない。

APIまたはCLIで作成・更新した場合も、Web画面で上記を確認する。画面で空欄の場合は、APIのレスポンスにDescriptionが存在していても完了とみなさず、画面のフィールドに値を設定し直す。

## 例外処理

- サインイン画面が表示された場合は、ユーザーに認証を依頼してから続行する。
- フィールド名や必須条件がプロジェクトによって異なる場合は、対象画面の表示を優先し、推測で登録しない。
- Parentリンクを設定できない場合は、作成済み項目を成功扱いにせず、IDと未完了のリンク設定を報告する。
- 保存後に欄が空の場合は、入力値の形式と対象フィールドを確認して再保存する。広範な例外を握りつぶしたり、本文だけを保存して終了したりしない。
- APIのエラー、権限不足、画面の入力エラーは、エラー内容と対象Work Itemを記録して報告する。

## 完了条件

- Web画面で対象種別の表示項目を確認した。
- 依頼内容を表示項目ごとに入力した。
- Work Itemが保存され、ID、種別、Title、親子リンクを確認した。
- BugまたはProduct Backlog Itemの主要な確認欄が画面上で空でない。
- Area、Iteration、Priorityなどの設定値と、未設定・未確認項目を報告した。
